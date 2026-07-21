require "test_helper"

class AttachmentSafetyTest < ActiveSupport::TestCase
  test "accepts a genuine PDF whose declared and detected types match" do
    with_upload("%PDF-1.4\n%%EOF\n", "document.pdf", "application/pdf") do |upload|
      assert AttachmentSafety.safe_upload?(upload)
    end
  end

  test "rejects a script disguised as a PDF" do
    with_upload("<script>alert(document.domain)</script>", "document.pdf", "application/pdf") do |upload|
      assert_not AttachmentSafety.safe_upload?(upload)
    end
  end

  test "rejects SVG even when it is declared as an image" do
    with_upload("<svg xmlns='http://www.w3.org/2000/svg'><script/></svg>", "image.svg", "image/svg+xml") do |upload|
      assert_not AttachmentSafety.safe_upload?(upload)
    end
  end

  test "model validation rejects a spoofed persisted attachment" do
    inquiry = inquiries(:one)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("not a pdf"),
      filename: "unsafe.pdf",
      content_type: "application/pdf",
      identify: false
    )
    inquiry.attachments.attach(blob)

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:attachments], "Inhalt und angegebener Dateityp stimmen nicht überein"
  end

  private

  def with_upload(content, filename, content_type)
    Tempfile.create([ "safe-upload", File.extname(filename) ]) do |file|
      file.binmode
      file.write(content)
      file.rewind
      upload = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: filename, type: content_type)
      yield upload
    end
  end
end
