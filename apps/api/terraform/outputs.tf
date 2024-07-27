output "api_id" {
  value = aws_appsync_graphql_api.example.id
}

output "api_key" {
  sensitive = true
  value     = aws_appsync_api_key.this.key
}

output "api_uris" {
  value = aws_appsync_graphql_api.example.uris
}
