# importing required modules
import boto3

def lambda_handler(event, context):
    # Creating an S3 client
    client = boto3.client('s3')
    
    # Method to list S3 buckets
    bucket_response = client.list_buckets(Filters=[{'Name': 'bucket-name'}])
    #print(bucket_response)
    
    # Set to store bucket names
    active_buckets = set()
    
    # Iterating through the bucket response and adding bucket names to a set
    for bucket in bucket_response['Buckets']:
       active_buckets.add(bucket['Name'])
    
    # Checking whether there is any active buckets for the account. Proceeding further only if there are any buckets.
    if not active_buckets:
        print("No S3 buckets found")
    else:
        # Printing the bucket names
        print("**********List of Buckets**********")
        print(active_buckets)
    
    # Iterating through the buckets and checking whether the bucket versioning is enabled or not.
    # Mail notification is sent to the user using SNS service if the bucket versioning is not enabled.
    # If the bucket versioning is enabled, checking whether the bucket contains any currnet or versioned objects. If the bucket is empty, then the bucket is deleted.
    for bucket_name in active_buckets:
        
        # Method to check bucket versioning
        versioning_response = client.get_bucket_versioning(Bucket=bucket_name)
        #print(versioning_response)
        status = versioning_response.get('Status', 'NotEnabled')
        
        print("**********Bucket versioning status**********")
        
        if status=="Enabled":
            print("Bucket versioning is enabled")
            
            # Method to return objects in a bucket
            object_response = client.list_objects(Bucket=bucket_name)
            #print(object_response)
            
            # Method to list versioned objects in the bucket
            object_version_response = client.list_object_versions(Bucket=bucket_name)
            #print(object_version_response)
        
            print("**********Bucket object status**********")
            
            # counting the number of objects in a bucket. If there are no objects, then deleting the bucket.
            if 'Contents' in object_response:
                object_count = len(object_response['Contents'])
                print("S3 bucket {0} contains {1} objects".format(bucket_name,object_count))
                
            if 'Versions' in object_version_response:
                object_version_count = len(object_version_response['Versions'])
                print("S3 bucket {0} contains {1} versioned objects".format(bucket_name,object_version_count))
            
            else:
                print("S3 bucket {0} is empty and hence deleting the ".format(bucket_name))
                client.delete_bucket(Bucket=bucket_name)
            
        # Sending mail notification if the bucket versioning is not enabled    
        else:
            print("Bucket versioning is not enabled")
            
            # Creating SNS client
            sns_client = boto3.client('sns')
            
            # Specify your SNS topic ARN
            sns_topic_arn = 'ENTER THE SNS TOPIC ARN'
            
            # Specify the message to be sent in the notification
            message = "Versioning is not enabled for the S3 bucket '{0}'. Please enable versioning or delete the bucket if no longer needed.".format(bucket_name)
            
            # Publish the message to the SNS topic
            sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="S3 Versioning Notification")
        
        
    
