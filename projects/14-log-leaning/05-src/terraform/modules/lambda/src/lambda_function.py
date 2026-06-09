import json

from aws_lambda_powertools import Logger

logger = Logger()


@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    """Log-friendly test handler using AWS Lambda Powertools.

    Query parameter `mode` can be set to `debug`, `warning`, or `error`
    to emit additional log lines for manual verification in CloudWatch.
    """
    query = event.get("queryStringParameters") or {}
    mode = query.get("mode", "info")

    logger.append_keys(test_mode=mode)
    logger.info("Request received")

    if mode == "debug":
        logger.debug("Debug log for test")
    elif mode == "warning":
        logger.warning("Warning log for test")
    elif mode == "error":
        logger.error("Error log for test")

    response_body = {
        "message": "powertools logging test ok",
        "mode": mode,
        "request_id": getattr(context, "aws_request_id", None),
    }

    logger.info("Returning response", extra={"response_body": response_body})

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(response_body),
    }
