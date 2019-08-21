module NilifyBlanks
  def array_or_hash?(obj)
    obj.is_a?(Array) || obj.is_a?(Hash)
  end

  def nilify_array_or_hash(obj)
    obj.reject! do |k, v|
      # Avoid separate reject! blocks for arrays & hashes
      v = k if obj.is_a?(Array)
      nilify_array_or_hash(v) if array_or_hash?(v)
      next unless v.respond_to?(:blank?)
      !v.is_a?(FalseClass) && v.blank?
    end
  end
end
