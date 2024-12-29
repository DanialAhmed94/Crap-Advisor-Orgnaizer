import 'dart:async'; // For TimeoutException
import 'dart:io';
import 'dart:convert'; // For base64 encoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../utilities/utilities.dart';
import '../../constants/AppConstants.dart'; // Ensure this import is present for AppConstants
import '../../annim/transition.dart';
import 'socialpstview.dart'; // Ensure this import points to your SocialMediaHomeView

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile>? _selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  // Flag to track upload state
  bool _isUploading = false;

  /// Helper method to map FirebaseException codes to user-friendly messages
  String getFirebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return "You don't have permission to perform this action.";
      case 'unavailable':
        return "Service is currently unavailable. Please try again later.";
      case 'network-request-failed':
        return "Network error. Please check your internet connection.";
      case 'invalid-argument':
        return "Invalid input provided. Please check and try again.";
      case 'deadline-exceeded':
        return "Request timed out. Please try again.";
      case 'already-exists':
        return "The item you're trying to add already exists.";
      case 'not-found':
        return "The requested item was not found.";
    // Add more cases as needed based on your app's requirements
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null) {
        setState(() {
          _selectedImages = pickedImages;
        });
      }
    } on FirebaseException catch (e) {
      // Handle Firebase-specific exceptions if any during image picking
      String errorMessage = getFirebaseErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred while picking images.")),
      );
    }
  }

  Future<void> _uploadPost() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_selectedImages == null || _selectedImages!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No images selected.")),
        );
        return;
      }

      // Encode each selected image as Base64 and store them in a list
      List<String> base64Images = [];
      for (XFile image in _selectedImages!) {
        // Convert file to bytes
        final File file = File(image.path);
        final bytes = await file.readAsBytes();

        // Encode bytes to base64
        final base64String = base64Encode(bytes);

        // Add to our list
        base64Images.add(base64String);
      }

      final bearerToken = await getToken();
      final userName = await getUserName();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? deviceId= await prefs.getString("fcm_token");
      // Store the post in Firestore with a timeout
      final String postId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .set({
        'userId': bearerToken, // Your user ID logic
        'fcmToken': deviceId, // Your user ID logic
        'description': _descriptionController.text.trim(),
        'images': base64Images, // List of base64 strings
        'createdAt': FieldValue.serverTimestamp(),
        'userName': userName,
        'likesCount': 0,
        'likes': [],
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("The connection has timed out. Please try again!");
      });

      // Clear fields after upload
      _descriptionController.clear();
      setState(() {
        _selectedImages = [];
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents dialog from closing on tap outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("Your post has been uploaded successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SocialMediaHomeView()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } on FirebaseException catch (e) {
      // Handle Firestore-specific exceptions
      String errorMessage = getFirebaseErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } on TimeoutException catch (e) {
      // Handle timeout exception
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network timeout. Please try again.")),
      );
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place the background image and the content
      body: Stack(
        children: [
          // Background Image
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
                  "Create Post",
                  style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: Image.asset(AppConstants.logo),
                  onPressed: null,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          // Main Content with SafeArea to avoid notches and system UI
          Positioned.fill(
            top: kToolbarHeight + 30, // Adjusted to account for AppBar height

            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Styled AppBar


                  // Description Input Field
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Ubuntu",
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: "Ubuntu",
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons Row: Pick Images & Upload Post
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pick Images Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickImages,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Pick Images"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Button color
                            foregroundColor: Colors.white, // Text and icon color
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Upload Post Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _uploadPost,
                          child: _isUploading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text("Upload Post"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Button color
                            foregroundColor: Colors.white, // Text color
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display Selected Images with Delete Option
                  if (_selectedImages != null && _selectedImages!.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages!.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.file(
                                    File(_selectedImages![index].path),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Delete Icon
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages!.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  if (_selectedImages != null && _selectedImages!.isNotEmpty)
                    const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}








//      using storage
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../utilities/utilities.dart'; // For generating unique IDs
//
// class CreatePostPage extends StatefulWidget {
//   @override
//   _CreatePostPageState createState() => _CreatePostPageState();
// }
//
// class _CreatePostPageState extends State<CreatePostPage> {
//   final TextEditingController _descriptionController = TextEditingController();
//   List<XFile>? _selectedImages = [];
//
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImages() async {
//     final List<XFile>? pickedImages = await _picker.pickMultiImage();
//     if (pickedImages != null) {
//       setState(() {
//         _selectedImages = pickedImages;
//       });
//     }
//   }
//
//   Future<void> _uploadPost() async {
//     try {
//       if (_selectedImages == null || _selectedImages!.isEmpty) {
//         // Provide feedback to user that images are required
//         return;
//       }
//
//       // Step 1: Upload images to Firebase Storage
//       List<String> imageUrls = [];
//       for (XFile image in _selectedImages!) {
//         String fileName = const Uuid().v4(); // unique ID for each image
//         UploadTask uploadTask = FirebaseStorage.instance
//             .ref('postImages/$fileName')
//             .putFile(File(image.path));
//
//         TaskSnapshot snapshot = await uploadTask;
//         String downloadUrl = await snapshot.ref.getDownloadURL();
//         imageUrls.add(downloadUrl);
//       }
//
//       final bearerToken = await getToken(); // Fetch the bearer token
//
//       // Step 2: Create a new post document in Firestore
//       String postId = const Uuid().v4();
//       await FirebaseFirestore.instance.collection('posts').doc(postId).set({
//         'userId': bearerToken, // Replace with actual user ID
//         'description': _descriptionController.text,
//         'images': imageUrls,
//         'createdAt': FieldValue.serverTimestamp(),
//         'likesCount': 0,
//         'likes': [],
//       });
//
//       // Clear fields after upload
//       _descriptionController.clear();
//       _selectedImages = [];
//
//       // Provide feedback to user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Post Uploaded Successfully!")),
//       );
//
//     } catch (e) {
//       // Handle error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error uploading post: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create Post"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Description Input
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ),
//
//             // Pick Images
//             ElevatedButton(
//               onPressed: _pickImages,
//               child: Text("Pick Images"),
//             ),
//
//             // Display Selected Images (optional preview)
//             _selectedImages != null && _selectedImages!.isNotEmpty
//                 ? Wrap(
//               children: _selectedImages!.map((image) {
//                 return Image.file(
//                   File(image.path),
//                   width: 100,
//                   height: 100,
//                   fit: BoxFit.cover,
//                 );
//               }).toList(),
//             )
//                 : Container(),
//
//             // Upload Button
//             ElevatedButton(
//               onPressed: _uploadPost,
//               child: Text("Upload Post"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
