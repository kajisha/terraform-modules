import uuid

import boto3


def generate_boto3_session(aws_iam_role_arn, region_name="ap-northeast-1"):
    client = boto3.client("sts")
    account_id = client.get_caller_identity()["Account"]

    response = client.assume_role(
        RoleArn=aws_iam_role_arn, RoleSessionName=str(uuid.uuid4())  # FIXME: script名とかから引けるようにする
    )

    session = boto3.session.Session(
        aws_access_key_id=response["Credentials"]["AccessKeyId"],
        aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
        aws_session_token=response["Credentials"]["SessionToken"],
        region_name=region_name,
    )
    return session
