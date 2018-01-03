require "zlib"
require "./lib/jekyll/zopfli/compressor"

RSpec.describe Jekyll::Zopfli::Compressor do
  let(:site) { make_site }

  it "is initialized with a Jekyll site" do
    compressor = Jekyll::Zopfli::Compressor.new(site)
    expect(compressor.site).to eq(site)
  end

  describe "given a file name" do
    before(:each) { site.process }
    after(:each) { FileUtils.rm_r(dest_dir) }

    let(:compressor) { Jekyll::Zopfli::Compressor.new(site) }

    it "creates a gzip file" do
      file_name = dest_dir("index.html")
      compressor.compress_file(file_name)
      expect(File.exist?("#{file_name}.gz")).to be true
    end

    it "creates a gzip file that is smaller than zlib" do
      file_name = dest_dir("index.html")
      compressor.compress_file(file_name)
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
      compressor.compress_file(file_name)
      content = File.read(file_name)
      Zlib::GzipReader.open("#{file_name}.gz") {|gz|
        expect(gz.read).to eq(content)
      }
    end

    it "doesn't compress non text files" do
      file_name = dest_dir("images/test.png")
      compressor.compress_file(file_name)
      expect(File.exist?("#{file_name}.gz")).to be false
    end

    it "compresses all files in the site" do
      compressor.compress
      files = [
        dest_dir("index.html"),
        dest_dir("css/main.css"),
        dest_dir("about/index.html"),
        dest_dir("jekyll/update/2018/01/01/welcome-to-jekyll.htlm"),
        dest_dir("feed.xml")
      ]
      files.each do |file_name|
        expect(File.exist?("#{file_name}.gz"))
      end
    end
  end
end