class AttachmentSafety
  MAX_BYTES = 25.megabytes
  DOCUMENT_TYPES = %w[application/pdf image/jpeg image/png image/webp].freeze
  IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze

  def self.safe_upload?(upload, allowed_types: DOCUMENT_TYPES, max_bytes: MAX_BYTES)
    return false unless upload.respond_to?(:size) && upload.respond_to?(:content_type)
    return false unless upload.size.to_i.between?(1, max_bytes)

    declared = upload.content_type.to_s.downcase
    return false unless declared.in?(allowed_types)

    detected = Marcel::MimeType.for(upload.tempfile).to_s.downcase
    upload.tempfile.rewind
    compatible_types?(declared, detected)
  rescue IOError, SystemCallError
    false
  end

  def self.validate(record, attachment, allowed_types: DOCUMENT_TYPES, max_bytes: MAX_BYTES)
    return unless attachment

    blob = attachment.blob
    record.errors.add(attachment.name, "darf nicht leer und höchstens #{max_bytes / 1.megabyte} MB groß sein") unless blob.byte_size.between?(1, max_bytes)
    declared = blob.content_type.to_s.downcase
    unless declared.in?(allowed_types)
      record.errors.add(attachment.name, "muss einen erlaubten PDF- oder Bildtyp haben")
      return
    end

    detected = blob.open { |io| Marcel::MimeType.for(io).to_s.downcase }
    record.errors.add(attachment.name, "Inhalt und angegebener Dateityp stimmen nicht überein") unless compatible_types?(declared, detected)
  rescue ActiveStorage::FileNotFoundError
    # Active Storage uploads a newly attached blob after the owning record's
    # validation. HTTP ingress is already signature-checked by safe_upload?;
    # persisted blobs are inspected on subsequent validations.
    nil
  rescue IOError, SystemCallError
    record.errors.add(attachment.name, "konnte nicht sicher geprüft werden")
  end

  def self.compatible_types?(declared, detected)
    declared == detected || (declared == "image/jpeg" && detected == "image/jpeg")
  end
  private_class_method :compatible_types?
end
