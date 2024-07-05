# IAM role for Lambda@Edge
resource "aws_iam_role" "lambda_edge_role" {
  name = "${var.pj}-lambda-edge-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# IAM policy for Lambda@Edge
resource "aws_iam_role_policy_attachment" "lambda_edge_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_edge_role.name
}

# Lambda@Edge function
resource "aws_lambda_function" "edge" {
  filename         = "lambda-edge-function.zip"
  function_name    = "nextjs-server-lambda-edge"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("lambda-edge-function.zip")
  runtime          = "nodejs20.x"
  publish          = true

  provider = aws.us-east-1  # Lambda@Edge must be in us-east-1
}
