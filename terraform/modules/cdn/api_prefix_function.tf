# The backend registers routes without an /api prefix (e.g. /health,
# /auth/login, /tasks). The frontend calls /api/* so CloudFront can
# route API traffic to the ALB origin. This viewer-request function
# strips the /api prefix before the request is forwarded to the ALB.
resource "aws_cloudfront_function" "strip_api_prefix" {
  name    = "starttech-strip-api-prefix"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-JS
    function handler(event) {
      var request = event.request;
      if (request.uri.startsWith('/api/')) {
        request.uri = request.uri.substring(4);
      } else if (request.uri === '/api') {
        request.uri = '/';
      }
      return request;
    }
  JS
}
