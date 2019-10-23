require "zlib"
require "./lib/jekyll/zopfli/compressor"

RSpec.describe Jekyll::Zopfli::Compressor do
  let(:site) { make_site }
  before(:each) { site.process }
  after(:each) { FileUtils.rm_r(dest_dir) }

  describe "given a file name" do
    it "creates a gzip file" do
      file_name = dest_dir("index.html")
      Jekyll::Zopfli::Compressor.compress_file(file_name, extensions: ['.html'])
      expect(File.exist?("#{file_name}.gz")).to be true
    end

    it "doesn't create a gzip file if the extension is not present" do
      file_name = dest_dir("index.html")
      Jekyll::Zopfli::Compressor.compress_file(file_name)
      expect(File.exist?("#{file_name}.gz")).to be false
    end

    it "creates a gzip file that is smaller than zlib" do
      file_name = dest_dir("index.html")
      Jekyll::Zopfli::Compressor.compress_file(file_name, extensions: ['.html'])
      zlib_file = dest_dir("zlib-index.html.gz")
      Zlib::GzipWriter.open(zlib_file, Zlib::BEST_COMPRESSION) do |gz|
        gz.mtime = File.mtime(file_name)
        gz.orig_name = file_name
        gz.write IO.binread(file_name)
      end
      expect(File.stat("#{file_name}.gz").size).to be < File.stat(zlib_file).size
    end

    it "compresses the content of the file in the gzip file" do
      file_name = dest_dir("index.html")
      Jekyll::Zopfli::Compressor.compress_file(file_name, extensions: ['.html'])
      content = File.read(file_name)
      Zlib::GzipReader.open("#{file_name}.gz") {|gz|
        expect(gz.read).to eq(content)
      }
    end

    it "doesn't compress non text files" do
      file_name = dest_dir("images/test.png")
      Jekyll::Zopfli::Compressor.compress_file(file_name, extensions: ['.html'])
      expect(File.exist?("#{file_name}.gz")).to be false
    end

    it "replaces the file if the settings say so" do
      file_name = dest_dir("index.html")
      original_file_size = File.size(file_name)
      content = File.read(file_name)
      Jekyll::Zopfli::Compressor.compress_file(file_name, extensions: ['.html'], replace_file: true)
      expect(File.exist?("#{file_name}")).to be true
      expect(File.exist?("#{file_name}.gz")).to be false
      expect(File.size(file_name)).to be < original_file_size
      Zlib::GzipReader.open("#{file_name}") {|gz|
        expect(gz.read).to eq(content)
      }
    end
  end

  describe "given a Jekyll site" do
    let(:files) {
      [
        dest_dir("index.html"),
        dest_dir("css/main.css"),
        dest_dir("about/index.html"),
        dest_dir("jekyll/update/2018/01/01/welcome-to-jekyll.html"),
        dest_dir("feed.xml")
      ]
    }

    it "compresses all files in the site" do
      Jekyll::Zopfli::Compressor.compress_site(site)
      puts Dir.glob("#{dest_dir('')}**/*")
      files.each do |file_name|
        expect(File.exist?("#{file_name}.gz")).to be true
      end
    end

    it "replaces the files if the settings say so" do
      original_stats = files.inject({}) { |hash, file|
        hash[file] = {size: File.size(file), content: File.read(file)}
        hash
      }

      site.config['zopfli'] ||= {}
      site.config['zopfli']['replace_files'] = true
      Jekyll::Zopfli::Compressor.compress_site(site)

      files.each { |file|
        expect(File.exist?("#{file}")).to be true
        expect(File.exist?("#{file}.gz")).to be false
        expect(File.size(file)).to be < original_stats[file][:size]
        Zlib::GzipReader.open("#{file}") {|gz|
          expect(gz.read).to eq(original_stats[file][:content])
        }
      }
    end

    describe "given a destination directory" do
      it "compresses all the text files in the directory" do
        Jekyll::Zopfli::Compressor.compress_directory(dest_dir, site)
        files.each do |file_name|
          expect(File.exist?("#{file_name}.gz")).to be true
        end
      end
    end
  end
end
