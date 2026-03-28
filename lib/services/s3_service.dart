import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config/aws_config.dart';

class S3Service {
  // ── Upload file to S3 ────────────────────────────────────────────────────────
  // Returns the S3 URL of the uploaded file, or throws an exception on failure
  static Future<String> uploadFile({
    required PlatformFile file,
    required String userId,
    required String folder,
  }) async {
    final fileBytes = file.bytes;
    if (fileBytes == null) {
      throw Exception('Could not read file bytes');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName  = file.name.replaceAll(' ', '_');
    final s3Key     = '$userId/$folder/${timestamp}_$fileName';
    final contentType = _getContentType(file.name);

    final now         = DateTime.now().toUtc();
    final dateStamp   = _formatDate(now);
    final amzDateTime = _formatDateTime(now);

    final host = '${AwsConfig.bucketName}.s3.${AwsConfig.region}.amazonaws.com';
    final url  = 'https://$host/$s3Key';

    final payloadHash      = sha256.convert(fileBytes).toString();
    final canonicalHeaders =
        'content-type:$contentType\n'
        'host:$host\n'
        'x-amz-content-sha256:$payloadHash\n'
        'x-amz-date:$amzDateTime\n';
    final signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest =
        'PUT\n/$s3Key\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';

    final credentialScope = '$dateStamp/${AwsConfig.region}/s3/aws4_request';
    final stringToSign =
        'AWS4-HMAC-SHA256\n$amzDateTime\n$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _getSigningKey(
        AwsConfig.secretAccessKey, dateStamp, AwsConfig.region, 's3');
    final signature  = Hmac(sha256, signingKey)
        .convert(utf8.encode(stringToSign))
        .toString();

    final authorization =
        'AWS4-HMAC-SHA256 '
        'Credential=${AwsConfig.accessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type':         contentType,
        'x-amz-date':           amzDateTime,
        'x-amz-content-sha256': payloadHash,
        'Authorization':        authorization,
      },
      body: fileBytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return url;
    } else {
      throw Exception('S3 upload failed: ${response.statusCode} ${response.body}');
    }
  }

  // ── Delete file from S3 ──────────────────────────────────────────────────────
  // Pass the full S3 URL (as stored in Firestore → fileUrl)
  // Returns true on success, throws on failure
  static Future<bool> deleteFile({required String fileUrl}) async {
    // ── Extract the S3 key from the URL ───────────────────────────────────────
    // URL format: https://{bucket}.s3.{region}.amazonaws.com/{key}
    final host = '${AwsConfig.bucketName}.s3.${AwsConfig.region}.amazonaws.com';
    final prefix = 'https://$host/';
    if (!fileUrl.startsWith(prefix)) {
      throw Exception('Invalid S3 URL: $fileUrl');
    }
    final s3Key = fileUrl.substring(prefix.length);

    // ── AWS Signature V4 for DELETE ───────────────────────────────────────────
    final now         = DateTime.now().toUtc();
    final dateStamp   = _formatDate(now);
    final amzDateTime = _formatDateTime(now);

    final url = 'https://$host/$s3Key';

    // DELETE has no body → payload hash is hash of empty string
    const payloadHash     = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    final canonicalHeaders =
        'host:$host\n'
        'x-amz-content-sha256:$payloadHash\n'
        'x-amz-date:$amzDateTime\n';
    const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest =
        'DELETE\n/$s3Key\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';

    final credentialScope = '$dateStamp/${AwsConfig.region}/s3/aws4_request';
    final stringToSign =
        'AWS4-HMAC-SHA256\n$amzDateTime\n$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _getSigningKey(
        AwsConfig.secretAccessKey, dateStamp, AwsConfig.region, 's3');
    final signature  = Hmac(sha256, signingKey)
        .convert(utf8.encode(stringToSign))
        .toString();

    final authorization =
        'AWS4-HMAC-SHA256 '
        'Credential=${AwsConfig.accessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'x-amz-date':           amzDateTime,
        'x-amz-content-sha256': payloadHash,
        'Authorization':        authorization,
      },
    );

    // S3 DELETE returns 204 No Content on success
    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('S3 delete failed: ${response.statusCode} ${response.body}');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  static String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':  return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      default:     return 'application/octet-stream';
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }

  static List<int> _getSigningKey(
      String secretKey, String dateStamp, String region, String service) {
    final kDate    = Hmac(sha256, utf8.encode('AWS4$secretKey'))
        .convert(utf8.encode(dateStamp)).bytes;
    final kRegion  = Hmac(sha256, kDate).convert(utf8.encode(region)).bytes;
    final kService = Hmac(sha256, kRegion).convert(utf8.encode(service)).bytes;
    final kSigning = Hmac(sha256, kService)
        .convert(utf8.encode('aws4_request')).bytes;
    return kSigning;
  }
}