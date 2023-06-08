import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

const String apiKey = 'LIVDSRZULELA';
const int pageSize = 10;
const int autocompleteLimit = 3;

class GifSearchWidget extends StatefulWidget {
  const GifSearchWidget({Key? key}) : super(key: key);

  @override
  _GifSearchWidgetState createState() => _GifSearchWidgetState();
}

class _GifSearchWidgetState extends State<GifSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _gifUrls = [];
  bool _isLoading = false;
  int _currentPage = 1;
  List<String> _autocompleteSuggestions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchGifs(String query, {bool loadMore = false}) async {
    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _gifUrls.clear();
        _currentPage = 1;
      }
    });

    final offset = (_currentPage - 1) * pageSize;
    final url =
        'https://g.tenor.com/v1/search?q=$query&key=$apiKey&limit=$pageSize&pos=$offset';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;

        for (var result in results) {
          final media = result['media'] as List<dynamic>;
          final gif = media[0]['gif'] as Map<String, dynamic>;
          final gifUrl = gif['url'] as String;

          setState(() {
            _gifUrls.add(gifUrl);
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
      _currentPage++;
    });
  }

  Future<List<String>> _getAutocompleteSuggestions(String query) async {
    final url =
        'https://g.tenor.com/v1/autocomplete?q=$query&key=$apiKey&limit=$autocompleteLimit';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['results'] as List<dynamic>;

        return suggestions.cast<String>();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return [];
  }

  void _updateAutocompleteSuggestions(String value) async {
    final suggestions = await _getAutocompleteSuggestions(value);
    setState(() {
      _autocompleteSuggestions = suggestions;
    });
  }

  void _selectAutocompleteSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchGifs(suggestion);

    setState(() {
      _autocompleteSuggestions.clear();
    });
  }

  void _shareGif(String gifUrl) {
    Share.share(gifUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search for GIFs',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _updateAutocompleteSuggestions(value);
            },
            onSubmitted: (value) {
              _searchGifs(value);
            },
          ),
        ),
        if (_autocompleteSuggestions.isNotEmpty)
          AutocompleteSuggestions(
            suggestions: _autocompleteSuggestions,
            onSuggestionSelected: _selectAutocompleteSuggestion,
          ),
        Expanded(
          child: GifResults(
            isLoading: _isLoading,
            gifUrls: _gifUrls,
            onLoadMore: () {
              _searchGifs(_searchController.text, loadMore: true);
            },
            onShare: _shareGif,
          ),
        ),
      ],
    );
  }
}

class AutocompleteSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;

  const AutocompleteSuggestions({
    Key? key,
    required this.suggestions,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () {
              onSuggestionSelected(suggestion);
            },
          );
        },
      ),
    );
  }
}

class GifResults extends StatelessWidget {
  final bool isLoading;
  final List<String> gifUrls;
  final VoidCallback onLoadMore;
  final Function(String) onShare;

  const GifResults({
    Key? key,
    required this.isLoading,
    required this.gifUrls,
    required this.onLoadMore,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading) const CircularProgressIndicator(),
        if (!isLoading && gifUrls.isEmpty) const Text('No results found.'),
        if (!isLoading && gifUrls.isNotEmpty)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: gifUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Flexible(
                        child: Image.network(
                          gifUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () {
                              // Handle save button pressed
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              onShare(gifUrls[index]);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (!isLoading && gifUrls.isNotEmpty)
          Container(
            child: ElevatedButton(
              onPressed: onLoadMore,
              child: const Text('Load More'),
            ),
          ),
      ],
    );
  }
}
