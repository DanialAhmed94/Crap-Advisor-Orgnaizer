import 'dart:convert'; // For decoding base64
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your custom transition and utilities
import '../../annim/transition.dart';
import '../../constants/AppConstants.dart';
import '../../utilities/utilities.dart';
import 'createPost.dart';

class SocialMediaHomeView extends StatefulWidget {
  const SocialMediaHomeView({Key? key}) : super(key: key);

  @override
  _SocialMediaHomeViewState createState() => _SocialMediaHomeViewState();
}

class _SocialMediaHomeViewState extends State<SocialMediaHomeView> {
  String? bearerToken;

  // Pagination state for posts
  final List<DocumentSnapshot> _postDocs = [];
  DocumentSnapshot? _lastPostDoc;
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;

  // NEW: Keep track of whether a like/unlike transaction is in-progress per post
  final Map<String, bool> _likeInProgressMap = {};

  static const int _postsPageSize = 10;

  @override
  void initState() {
    super.initState();
    loadToken();
    _fetchPosts();
  }

  Future<void> loadToken() async {
    bearerToken = await getToken(); // Fetch the bearer token
    setState(() {}); // Update UI after token is loaded
  }

  /// Fetch a page of posts
  Future<void> _fetchPosts() async {
    if (_isLoadingPosts || !_hasMorePosts) return;
    setState(() {
      _isLoadingPosts = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_postsPageSize);

    if (_lastPostDoc != null) {
      query = query.startAfterDocument(_lastPostDoc!);
    }

    final snap = await query.get();
    print('Fetched ${snap.docs.length} docs');
    for (var d in snap.docs) {
      print(d.data());
    }

    if (snap.docs.isNotEmpty) {
      _lastPostDoc = snap.docs.last;
      _postDocs.addAll(snap.docs);
    }

    if (snap.docs.length < _postsPageSize) {
      _hasMorePosts = false;
    }

    setState(() {
      _isLoadingPosts = false;
    });
  }

  /// Refresh posts (used for pull-to-refresh and after adding a new post)
  Future<void> _refreshPosts() async {
    setState(() {
      _postDocs.clear();
      _lastPostDoc = null;
      _hasMorePosts = true;
    });
    await _fetchPosts();
  }

  /// Formats the post time based on the difference from the current time.
  String _formatPostTime(DateTime createdAt) {
    final Duration difference = DateTime.now().difference(createdAt);

    if (difference.inHours < 24) {
      return '${difference.inHours} Hr${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      // Format the date as per your preference, e.g., Aug 25, 2023
      return '${_getMonthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}';
    }
  }

  /// Returns the month name based on the month number.
  String _getMonthName(int monthNumber) {
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts, // Enables pull-to-refresh
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppConstants.planBackground,
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: AppBar(
                  title: Text(
                    "Feed",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: CircleAvatar(
                      backgroundImage: AssetImage('${AppConstants.logo}'),
                    ),
                    onPressed: null,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            // Positioned fill - show list of paginated posts
            Positioned.fill(
              top: kToolbarHeight + 30, // Adjusted to account for AppBar height
              child: _buildPostList(),
            ),
          ],
        ),
      ),

      // FloatingActionButton to create a new post
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            FadePageRouteBuilder(widget: CreatePostPage()),
          );
          await _refreshPosts(); // Refresh posts after creating a new one
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds a ListView of currently loaded posts + a load-more row at the end
  Widget _buildPostList() {
    if (_postDocs.isEmpty && _isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_postDocs.isEmpty && !_isLoadingPosts) {
      return const Center(child: Text("No posts yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _postDocs.length + 1, // extra item for load-more indicator
      itemBuilder: (context, index) {
        if (index == _postDocs.length) {
          // The "Load More" or "No more posts" row
          if (_hasMorePosts) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoadingPosts
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _fetchPosts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text("Load More Posts"),
                      ),
              ),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("No more posts."),
              ),
            );
          }
        }

        final doc = _postDocs[index];
        final postId = doc.id;
        // Grab postData statically here (so no real-time streaming for everything):
        final postData = doc.data() as Map<String, dynamic>;

        return PostItemWidget(
          postId: postId,
          bearerToken: bearerToken,
          parentState: this,
          postData: postData, // pass the static data
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Methods below are called by PostItemWidget (for building post UI, etc.)
  // -------------------------------------------------------------------------
  Widget buildPostItemUI(
    BuildContext context,
    Map<String, dynamic> postData,
    String postId,
  ) {
    final String description = postData['description'] ?? '';
    final List images = postData['images'] ?? []; // base64 strings
    final int likesCount = postData['likesCount'] ?? 0; // still read once
    final List likes = postData['likes'] ?? []; // still read once
    final String userName = postData['userName'].toString();

    // Ensure 'createdAt' is a Timestamp and convert to DateTime
    final Timestamp timestamp = postData['createdAt'] as Timestamp;
    final DateTime createdAt = timestamp.toDate();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        // Some padding to give breathing room on all screens
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info + Time
            ListTile(
              leading:  CircleAvatar(
                backgroundImage: AssetImage(AppConstants.logo),
              ),
              title: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              trailing: Text(
                _formatPostTime(createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            // Post Images (Horizontal List if multiple images)
            if (images.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: images.map((base64Str) {
                    try {
                      final decodedBytes = base64Decode(base64Str);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.memory(
                            decodedBytes,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle decoding error
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ),
              ),

            // Description
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 16,
                  ),
                ),
              ),

            // Like and Comment Row (REPLACED with LikeSectionWidget to see real-time likes)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LikeSectionWidget(
                postId: postId,
                bearerToken: bearerToken,
                parentState: this,
              ),
            ),

            // Comments inside an ExpansionTile with customized divider
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  'View/Add Comments',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  CommentSectionWidget(postId: postId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Like / Unlike logic (updated to prevent spam-tapping and ensure >= 0)
  Future<void> handleLike(
    BuildContext context,
    String postId,
    List likes,
  ) async {
    String? currentUserId = bearerToken;
    if (currentUserId == null) {
      // Optionally, prompt user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
      return;
    }

    // If a like/unlike transaction is already in progress, return
    if (_likeInProgressMap[postId] == true) return;
    _likeInProgressMap[postId] = true;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    // Use a Firestore transaction to handle concurrency and avoid negative counts
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final List currentLikes = data['likes'] ?? [];
      final int currentLikesCount = data['likesCount'] ?? 0;

      if (currentLikes.contains(currentUserId)) {
        // Unlike
        // likesCount should not go below zero:
        final newCount = currentLikesCount > 0 ? currentLikesCount - 1 : 0;
        transaction.update(postRef, {
          'likes': FieldValue.arrayRemove([currentUserId]),
          'likesCount': newCount,
        });
      } else {
        // Like
        transaction.update(postRef, {
          'likes': FieldValue.arrayUnion([currentUserId]),
          'likesCount': currentLikesCount + 1,
        });
      }
    }).whenComplete(() {
      _likeInProgressMap[postId] = false;
    }).catchError((_) {
      _likeInProgressMap[postId] = false;
    });
  }

  /// Add a comment to Firestore
  Future<void> addComment(String postId, String commentText) async {
    if (commentText.isEmpty) return;

    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');

    final token = await getToken();

    await commentsRef.add({
      'userId': token,
      'commentText': commentText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// -------------------------------------------------------------------
// PostItemWidget: REMOVED the original full-post StreamBuilder
// -------------------------------------------------------------------
class PostItemWidget extends StatelessWidget {
  final String postId;
  final String? bearerToken;
  final _SocialMediaHomeViewState parentState;

  // We now also receive static 'postData' from _buildPostList
  final Map<String, dynamic> postData;

  const PostItemWidget({
    Key? key,
    required this.postId,
    required this.bearerToken,
    required this.parentState,
    required this.postData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instead of streaming the entire post,
    // we simply build the UI with the static postData
    return parentState.buildPostItemUI(context, postData, postId);
  }
}

// -------------------------------------------------------------------
// CommentSectionWidget: Paginates comments, 10 at a time (unchanged)
// -------------------------------------------------------------------
class CommentSectionWidget extends StatefulWidget {
  final String postId;

  const CommentSectionWidget({Key? key, required this.postId})
      : super(key: key);

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  // Pagination state for comments
  final List<DocumentSnapshot> _commentDocs = [];
  DocumentSnapshot? _lastCommentDoc;
  bool _isLoadingComments = false;
  bool _hasMoreComments = true;

  static const int _commentsPageSize = 10;

  final TextEditingController _commentController = TextEditingController();

  // NEW: Prevent multiple identical comment submissions if tapped repeatedly
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  /// Fetch a page of comments for this post
  Future<void> _fetchComments() async {
    if (_isLoadingComments || !_hasMoreComments) return;
    setState(() {
      _isLoadingComments = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(_commentsPageSize);

    if (_lastCommentDoc != null) {
      query = query.startAfterDocument(_lastCommentDoc!);
    }

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      _lastCommentDoc = snap.docs.last;
      _commentDocs.addAll(snap.docs);
    }

    if (snap.docs.length < _commentsPageSize) {
      _hasMoreComments = false;
    }

    setState(() {
      _isLoadingComments = false;
    });
  }

  /// Adds a new comment
  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // If a comment add is already in progress, do nothing
    if (_isAddingComment) return;
    _isAddingComment = true;

    final token = await getToken();
    final userName = await getUserName();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = await prefs.getString("fcm_token");
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userName': userName,
      'fcmToken': deviceId,
      'userId': token,
      'commentText': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
    // Refresh comments to include the new one
    await _refreshComments();

    // Allow next comment
    _isAddingComment = false;
  }

  /// Refresh from scratch (e.g., after adding a comment)
  Future<void> _refreshComments() async {
    setState(() {
      _commentDocs.clear();
      _lastCommentDoc = null;
      _hasMoreComments = true;
    });
    await _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comments List
        _buildCommentsList(),
        // "Load More Comments" or "No more comments."
        if (_commentDocs.isNotEmpty) _buildLoadMoreCommentsBtn(),
        const SizedBox(height: 8),
        // Styled TextField to add comment
        _buildAddCommentField(),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (_commentDocs.isEmpty && _isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_commentDocs.isEmpty && !_isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No comments yet. Be the first to comment!'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _commentDocs.length,
      itemBuilder: (context, index) {
        final doc = _commentDocs[index];
        final data = doc.data() as Map<String, dynamic>;
        final commentText = data['commentText'] ?? '';
        final userName = data['userName'] ?? 'Anonymous';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar or Placeholder
              const CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Optionally, display the username
                      Text('$userName:'),
                      const SizedBox(width: 4),
                      // NEW: Wrap commentText in Expanded to allow large text to wrap
                      Expanded(
                        child: Text(
                          commentText,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreCommentsBtn() {
    if (_hasMoreComments) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoadingComments
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _fetchComments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("Load More Comments"),
              ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("No more comments.")),
      );
    }
  }

  /// Styled comment input field with rounded corners and send button
  Widget _buildAddCommentField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // Slight background color & rounding for the text field
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// LikeSectionWidget: Streams only 'likes' and 'likesCount' in real time
// -------------------------------------------------------------------
class LikeSectionWidget extends StatelessWidget {
  final String postId;
  final String? bearerToken;
  final _SocialMediaHomeViewState parentState;

  const LikeSectionWidget({
    Key? key,
    required this.postId,
    required this.bearerToken,
    required this.parentState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final postData = snapshot.data!.data() as Map<String, dynamic>;
        final int likesCount = postData['likesCount'] ?? 0;
        final List likes = postData['likes'] ?? [];

        return Row(
          children: [
            // The same like button logic from your original code
            InkWell(
              onTap: () => parentState.handleLike(context, postId, likes),
              child: Row(
                children: [
                  Icon(
                    likes.contains(bearerToken)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        likes.contains(bearerToken) ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(likesCount.toString()),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Comment icon is static
            Row(
              children: const [
                Icon(Icons.comment, color: Colors.grey),
                SizedBox(width: 4),
                Text('Comments'),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ****** images were shown using Storgae
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../../annim/transition.dart';
// import '../../utilities/utilities.dart';
// import 'createPost.dart';
//
// class SocialMediaHomeView extends StatefulWidget {
//   const SocialMediaHomeView({Key? key}) : super(key: key);
//
//   @override
//   _SocialMediaHomeViewState createState() => _SocialMediaHomeViewState();
// }
//
// class _SocialMediaHomeViewState extends State<SocialMediaHomeView> {
//   String? bearerToken;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadToken();
//
//   }
//   Future<void> loadToken()async{
//    bearerToken = await getToken(); // Fetch the bearer token
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Any background or AppBar widgets can go here...
//
//           // Positioned Fill - show list of posts
//           Positioned.fill(
//             top: MediaQuery.of(context).size.height * 0.11,
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('posts')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final posts = snapshot.data!.docs;
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: posts.length,
//                   itemBuilder: (context, index) {
//                     final postDoc = posts[index];
//                     final postData = postDoc.data() as Map<String, dynamic>;
//                     final postId = postDoc.id;
//
//                     return _buildPostItem(context, postData, postId);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // FloatingActionButton to create new post
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: CreatePostPage()));
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   /// Builds each individual post card.
//   Widget _buildPostItem(BuildContext context, Map<String, dynamic> postData, String postId) {
//     final String description = postData['description'] ?? '';
//     final List images = postData['images'] ?? [];
//     final int likesCount = postData['likesCount'] ?? 0;
//     final List likes = postData['likes'] ?? [];
//
//     return Card(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       elevation: 4,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // User Info + Time
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundImage: AssetImage('assets/images/user.png'),
//             ),
//             title: const Text('James'),  // Demo only; consider dynamic user data
//             subtitle: const Text('London, UK'),
//             trailing: const Text('2 Hr ago'),  // Demo only; consider using createdAt
//           ),
//
//           // Post Images (Horizontal List if multiple images)
//           if (images.isNotEmpty)
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: images.map((imageUrl) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15.0),
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         height: MediaQuery.of(context).size.height * 0.3,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//
//           // Description
//           if (description.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 description,
//                 style: const TextStyle(
//                   fontFamily: "Ubuntu",
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//
//           // Like and Comment Row
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Row(
//               children: [
//                 // Like Button
//                 InkWell(
//                   onTap: () => _handleLike(context, postId, likes),
//                   child: Row(
//                     children: [
//                       Icon(
//                         likes.contains(bearerToken)
//                             ? Icons.favorite
//                             : Icons.favorite_border,
//                         color: likes.contains(bearerToken)
//                             ? Colors.red
//                             : Colors.grey,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(likesCount.toString()),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//
//                 // A simple comment icon or label
//                 Row(
//                   children: const [
//                     Icon(Icons.comment, color: Colors.grey),
//                     SizedBox(width: 4),
//                     Text('Comments'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // ExpansionTile to show + add comments
//           ExpansionTile(
//             title: const Text(
//               'View/Add Comments',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             children: [
//               // 1) Comments List
//               _buildCommentsList(postId),
//
//               // 2) TextField to Add a Comment
//               _buildAddCommentField(postId),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Real-time comments list for a given post
//   Widget _buildCommentsList(String postId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('posts')
//           .doc(postId)
//           .collection('comments')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         final comments = snapshot.data!.docs;
//         if (comments.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('No comments yet. Be the first to comment!'),
//           );
//         }
//
//         return ListView.builder(
//           // Use shrinkWrap + no scrolling to avoid conflict with the main ListView
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: comments.length,
//           itemBuilder: (context, index) {
//             final commentDoc = comments[index];
//             final commentData = commentDoc.data() as Map<String, dynamic>;
//             final commentText = commentData['commentText'] ?? '';
//             final commentUserId = commentData['userId'] ?? 'Unknown';
//
//             return ListTile(
//               title: Text(commentText),
//               subtitle: Text('User: $commentUserId'),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   /// A row with a TextField + send button to add a comment
//   Widget _buildAddCommentField(String postId) {
//     final TextEditingController _commentController = TextEditingController();
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           // Text field for typing comment
//           Expanded(
//             child: TextField(
//               controller: _commentController,
//               decoration: const InputDecoration(
//                 labelText: 'Add a comment...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//
//           // Send button
//           IconButton(
//             icon: const Icon(Icons.send, color: Colors.blue),
//             onPressed: () async {
//               final commentText = _commentController.text.trim();
//               if (commentText.isNotEmpty) {
//                 await _addComment(postId, commentText);
//                 _commentController.clear();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Helper to add a new comment document to the post's sub-collection
//   Future<void> _addComment(String postId, String commentText) async {
//     if (commentText.isEmpty) return;
//
//     final CollectionReference commentsRef = FirebaseFirestore.instance
//         .collection('posts')
//         .doc(postId)
//         .collection('comments');
//
//     final bearerToken = await getToken(); // Fetch the bearer token
//
//     // Replace 'exampleUserId' with the real UID from FirebaseAuth.currentUser
//     await commentsRef.add({
//       'userId': bearerToken,
//       'commentText': commentText,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   /// Like / Unlike logic
//   Future<void> _handleLike(BuildContext context, String postId, List likes) async {
//     String? currentUserId = bearerToken; // Replace with your actual userId
//     DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
//
//     if (likes.contains(currentUserId)) {
//       // Unlike
//       await postRef.update({
//         'likes': FieldValue.arrayRemove([currentUserId]),
//         'likesCount': FieldValue.increment(-1),
//       });
//     } else {
//       // Like
//       await postRef.update({
//         'likes': FieldValue.arrayUnion([currentUserId]),
//         'likesCount': FieldValue.increment(1),
//       });
//     }
//   }
// }
