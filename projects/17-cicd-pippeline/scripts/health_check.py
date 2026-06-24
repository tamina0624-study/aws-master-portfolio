#!/usr/bin/env python3
"""Health check script for CICD deployment validation."""

import os
import sys
import boto3
from botocore.exceptions import ClientError


def check_s3_bucket(bucket_name: str) -> dict[str, bool]:
    """Check S3 bucket accessibility and basic properties."""
    s3_client = boto3.client("s3")
    results = {
        "bucket_exists": False,
        "versioning_enabled": False,
        "tags_present": False,
    }

    try:
        # Check bucket exists
        s3_client.head_bucket(Bucket=bucket_name)
        results["bucket_exists"] = True
        print(f"✓ S3 bucket exists: {bucket_name}")

        # Check versioning
        versioning = s3_client.get_bucket_versioning(Bucket=bucket_name)
        is_versioning_enabled = versioning.get("Status") == "Enabled"
        results["versioning_enabled"] = is_versioning_enabled
        print(f"✓ Versioning: {'Enabled' if is_versioning_enabled else 'Disabled'}")

        # Check tags
        try:
            tags_response = s3_client.get_bucket_tagging(Bucket=bucket_name)
            tag_set = tags_response.get("TagSet", [])
            results["tags_present"] = len(tag_set) > 0
            print(f"✓ Tags present: {len(tag_set)} tag(s) found")
            for tag in tag_set:
                print(f"  - {tag['Key']}: {tag['Value']}")
        except ClientError as e:
            if e.response["Error"]["Code"] != "NoSuchTagSet":
                raise
            results["tags_present"] = False
            print("⚠ No tags found on bucket")

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        print(f"✗ Error checking bucket '{bucket_name}': {error_code}")
        return results

    return results


def health_check() -> bool:
    """Run all health checks and return overall status."""
    bucket_name = os.getenv("S3_BUCKET_NAME")

    if not bucket_name:
        print("✗ S3_BUCKET_NAME environment variable not set")
        return False

    print(f"\n=== Health Check for {bucket_name} ===")
    results = check_s3_bucket(bucket_name)

    print("\n=== Health Check Summary ===")
    all_passed = all(results.values())

    for check_name, passed in results.items():
        status = "✓" if passed else "✗"
        print(f"{status} {check_name}: {'PASS' if passed else 'FAIL'}")

    if all_passed:
        print("\n✅ All health checks passed!")
    else:
        print("\n❌ Some health checks failed!")

    return all_passed


if __name__ == "__main__":
    success = health_check()
    sys.exit(0 if success else 1)
