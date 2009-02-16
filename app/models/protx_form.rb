class String
  def ^(other)
    if other.empty?
      self
    else
      a1 = self.unpack("c*")
      a2 = other.unpack("c*")

      a2 *= a1.length/a2.length + 1

      a1.zip(a2).collect{|c1,c2| c1^c2}.pack("c*")
    end
  end
end

class ProtxForm
  attr_accessor :encryption_key, :url, :vendor_code, :app_key
  
  def initialize(params={})
    self.url = params[:url]
    self.vendor_code = params[:login]
    self.encryption_key = params[:encryption_key]
    self.app_key = params[:app_key] || `hostname`.strip
  end
  
  def form_fields(object, success_url, failure_url)
    object_details = object.protx_hash.merge(
      'VendorTxCode' => "#{app_key}-#{object.class.name.tableize}-#{object.id}",
      'AllowGiftAid' => '1',
      'SuccessURL' => success_url,
      'FailureURL' => failure_url
    )
    p object_details
    {
      'TXType' => 'PAYMENT',
      'VPSProtocol' => '2.22',
      'Vendor' => vendor_code,
      'Crypt' => encrypt_for_protx(object_details)
    }
  end
  
  def parse_response(crypt)
    params = decrypt_from_protx(crypt)
    obj_key, obj_id = "#{$2.singularize}_id".to_sym, $3 if params['VendorTxCode'] =~ /(.*?)-(.*?)-(\d+)/
    {
      :params => params, 
      :status => params['Status'],
      :transaction_id => params['TxAuthNo'],
      obj_key => obj_id
    }
  end
  
  private
  
  def decrypt_from_protx(crypt)
    string = Base64.decode64(crypt) ^ encryption_key
    hash = CGI.parse(string)
    hash.each { |k,v| hash[k] = v.first if v.size==1 }
    hash
  end
  
  def encrypt_for_protx(values)
    string = values.map { |k,v| "#{k}=#{v}" }.join('&')
    Base64.encode64(string ^ encryption_key).gsub("\n", '')
  end
end