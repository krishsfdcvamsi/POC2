/*
Author Name   : I. Martinez
Created Date  : Aug 15, 2019 
Description   : HTTP Mockfactory used by integration test classes

History
*
* 15AUG2019 | I Martinez | | Initial version 
*/
@isTest
public class RFO_HTTPMockFactory implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    /* Constructors */
    public RFO_HTTPMockFactory(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    /* HTTP Response method */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}