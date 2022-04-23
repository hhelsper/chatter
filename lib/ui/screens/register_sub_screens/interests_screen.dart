import 'package:flutter/material.dart';

class InterestsScreen extends StatefulWidget {

  InterestsScreen({required this.onInterestsChanged, Key? key}) : super(key: key);
  late final Function(List<String>) onInterestsChanged;




  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<String> interests = ['hiking',
    'sports', 'gaming', 'anime', 'comedy',
    'movies', 'tv\nshows', 'music', 'coffee',
    'brunch', 'pizza', 'food', 'art', 'reading',
    'gym', 'cycling', 'running', 'drinking',
    'board\ngames', 'fashion',
    'baking', 'cooking', 'dancing', 'golfing'];

  List<String> SelectedInterests = [];
  late List<bool> _selectedList;



  @override
  void initState(){
    super.initState();
    _selectedList = List.filled(interests.length, false, growable: true);

  }
  @override
  Widget build(BuildContext context) {




    return Column(
      children: <Widget>[
        Text(
          'Interests',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 22),
        Expanded(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: interests.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext ctx, index) {

                return Center(
                  child: InkWell(
                    onTap: (){
                        print("clicked index number : $index");
                      print(_selectedList[index].toString());

                      _selectedList[index] = true;

                      print(_selectedList[index].toString());

                      if(!SelectedInterests.contains(interests[index])) {
                        SelectedInterests.add(interests[index]);
                      } else if(SelectedInterests.contains(interests[index])){
                        SelectedInterests.remove(interests[index]);
                        _selectedList[index]=false;
                      }
                      print(SelectedInterests.toString());

                        widget.onInterestsChanged(SelectedInterests);
                        setState(() {

                        });
                      },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(interests[index]),
                      decoration: _selectedList[index] ? BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15)) :
                      BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
