class Post {
  final int id;
  final String createdAt;
  final int score;
  final int width;
  final int height;
  final String md5;
  final String directory;
  final String image;
  final String rating;
  final String source;
  final int change;
  final String owner;
  final int creatorId;
  final int parentId;
  final int sample;
  final int previewHeight;
  final int previewWidth;
  final String tags;
  final String title;
  final String hasNotes;
  final String hasComments;
  final String fileUrl;
  final String previewUrl;
  final String sampleUrl;
  final int sampleHeight;
  final int sampleWidth;
  final String status;
  final int postLocked;
  final String hasChildren;

  const Post({
    required this.id,
    required this.createdAt,
    required this.score,
    required this.width,
    required this.height,
    required this.md5,
    required this.directory,
    required this.image,
    required this.rating,
    required this.source,
    required this.change,
    required this.owner,
    required this.creatorId,
    required this.parentId,
    required this.sample,
    required this.previewHeight,
    required this.previewWidth,
    required this.tags,
    required this.title,
    required this.hasNotes,
    required this.hasComments,
    required this.fileUrl,
    required this.previewUrl,
    required this.sampleUrl,
    required this.sampleHeight,
    required this.sampleWidth,
    required this.status,
    required this.postLocked,
    required this.hasChildren,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "created_at": String createdAt,
        "score": int score,
        "width": int width,
        "height": int height,
        "md5": String md5,
        "directory": String directory,
        "image": String image,
        "rating": String rating,
        "source": String source,
        "change": int change,
        "owner": String owner,
        "creator_id": int creatorId,
        "parent_id": int parentId,
        "sample": int sample,
        "preview_height": int previewHeight,
        "preview_width": int previewWidth,
        "tags": String tags,
        "title": String title,
        "has_notes": String hasNotes,
        "has_comments": String hasComments,
        "file_url": String fileUrl,
        "preview_url": String previewUrl,
        "sample_url": String sampleUrl,
        "sample_height": int sampleHeight,
        "sample_width": int sampleWidth,
        "status": String status,
        "post_locked": int postLocked,
        "has_children": String hasChildren,
      } =>
        Post(
          id: id,
          createdAt: createdAt,
          score: score,
          width: width,
          height: height,
          md5: md5,
          directory: directory,
          image: image,
          rating: rating,
          source: source,
          change: change,
          owner: owner,
          creatorId: creatorId,
          parentId: parentId,
          sample: sample,
          previewHeight: previewHeight,
          previewWidth: previewWidth,
          tags: tags,
          title: title,
          hasNotes: hasNotes,
          hasComments: hasComments,
          fileUrl: fileUrl,
          previewUrl: previewUrl,
          sampleUrl: sampleUrl,
          sampleHeight: sampleHeight,
          sampleWidth: sampleWidth,
          status: status,
          postLocked: postLocked,
          hasChildren: hasChildren,
        ),
      _ => throw const FormatException("Failed to load post."),
    };
  }
}
