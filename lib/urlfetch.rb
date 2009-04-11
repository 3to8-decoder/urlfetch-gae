require 'java'

module URLFetch
  module UFS #Url Fetch Service
    import com.google.appengine.api.urlfetch.URLFetchServiceFactory
    import com.google.appengine.api.urlfetch.FetchOptions
    import com.google.appengine.api.urlfetch.HTTPHeader
    import com.google.appengine.api.urlfetch.HTTPRequest
    import com.google.appengine.api.urlfetch.HTTPResponse
    import com.google.appengine.api.urlfetch.HTTPMethod
    import java.net.URL
    Service = URLFetchServiceFactory.getURLFetchService
  end
  class HTTPResponse
    def initialize javaobject
      @code = javaobject.getResponseCode() 
      @content = String.from_java_bytes javaobject.getContent() if javaobject.getContent()
      @header_hash = {}
      @headers = []
      javaobject.getHeaders().each do |header|
        @header_hash[header.name] = header.value
        @headers << [header.name,header.value]
      end
    end
    attr_accessor :code,:header_hash,:content,:headers
    def to_s
      @content
    end
  end
  
  def self.get url,options={}
    fetch request_object(url,:GET,nil,options)
  end
  def self.post url,payload,options={}
    fetch request_object(url,:POST,payload,options)
  end  
  def self.put url,payload,options={}
    fetch request_object(url,:PUT,payload,options)
  end
  def self.delete url,options={}
    fetch request_object(url,:DELETE,nil,options)
  end
  def self.head url,options={}
    fetch request_object(url,:HEAD,nil,options)
  end

  def self.fetch request
    HTTPResponse.new UFS::Service.fetch(request)
  end
  def self.request_object url,method=:GET,payload=nil,options={}
    opt = UFS::FetchOptions::Builder.allowTruncate unless options[:truncate] == false  
    opt = UFS::FetchOptions::Builder.disallowTruncate if options[:truncate] == false    
    opt = opt.doNotFollowRedirects if options[:redirect] == false    
    req = UFS::HTTPRequest.new(UFS::URL.new(url),UFS::HTTPMethod.valueOf(method.to_s),opt)
    req.payload = payload.to_java_bytes if payload != nil
    if options[:header]
      options[:header].each do |key,value|
        req.add_header UFS::HTTPHeader.new(key.to_s,value.to_s)
      end
    end    
    req
  end  
end


