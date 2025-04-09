import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import '../controllers/profile_controller.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';



class AnalyticsView extends StatefulWidget{
    final Users? users;
    const AnalyticsView({Key?key, this.users}): super (key: key);
  
    @override 
    State<AnalyticsView> createState()=> _AnalyticsViewState();

}

class _AnalyticsViewState extends  State<AnalyticsView> {
  late final User?user;
  late final ProfileController _profileController;
  final EventController _eventController = EventController();
  String?type;
  String?role;
  Event?selectedEvent;
  bool isLoading=false;

  Map<String, int> attendeeType={
    'organizer':0,
    'Stakeholders':0,
    'administration':0,
    'attendee':0,
  };

    @override
  void initState() {
    super.initState();
        user= FirebaseAuth.instance.currentUser!;
      _profileController= ProfileController(AuthService());
  }

  Future <void> _updateAttendeeData(Event event) async{
    setState((){
      isLoading=true;
      selectedEvent=event;
    });
      try {
        List<Map<String, dynamic>> attendees = await _eventController.getEventAttendees(event.id);
         Map<String, int> counts={
            'organizer':0,
            'Stakeholders':0,
            'administration':0,
            'attendee':0,
          };

          for (var attendee in attendees){
            String userRole=attendee['role']??'attendee';
            if(counts.containsKey(userRole)){
              counts[userRole]=(counts[userRole]??0)+1;
            }else {
              counts[userRole]=1;
            }
          }

          setState((){
            attendeeType=counts;
            isLoading=false;
          });
      } catch (e){
        print('ERROR GETTING ATTENDEE DATA : $e');
        setState((){
          isLoading=false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-time Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Track attendee participation, event success metrics, and collect feedback in real-time.',
              style: TextStyle(fontSize: 16),
            ),
         
            //if(user != null&& (_profileController.getRoleById(user!.uid)) == 'organizer')
            _buildMyOrganizedEventsList(context),

            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children:[
                  Expanded(
                    flex:1,
                      child:Column(
                        children: [
                          Expanded(
                            flex:1,
                            child: _buildMetricCard('Attendee Participation', '75% Active'),
                          ),
                          Expanded(
                            flex:2,
                            child: _buildPieChart('Attendees Participation', 'Total'), 
                          )
                        ],
                      ),
                    ),
                  Expanded(
                    flex:1,
                    child: Card(
                      margin:EdgeInsets.all(8),
                      child:Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children:[
                            Text('Event Analytics',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height:10),
                            //Text('TESTING')
                             Expanded(
                            child: selectedEvent == null
                                ? Center(child: Text('Select an event to view sponsor analytics'))
                                : _buildSponsorGraph(selectedEvent!),
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      margin: EdgeInsets.all(8),
      child:
      Padding(
        padding:const EdgeInsets.symmetric(vertical:20, horizontal:16),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value),
          leading: const Icon(Icons.analytics, color: Color.fromARGB(255, 118, 157, 123)),
          ),
      ),
    );
  }

    Widget _buildPieChart(String title, String subtitle) {


      Map<String, Color> roleColors={
        'organizer':Colors.green,
        'Stakeholders':Colors.red,
        'administration':Colors.yellow,
        'attendee':Colors.blue,
      };

      if (isLoading || selectedEvent ==null){
        return Card(
          margin:EdgeInsets.all(8),
          child:Container(
            height:double.infinity,
            child:Center(
              child:selectedEvent==null? Text('Select one of the events to view analytics!'):CircularProgressIndicator(),
            ),
          ),
        );
      }

      List<PieChartSectionData> sections=[];
      int total=attendeeType.values.fold(0,(sum,count)=> sum+count);

      if(total==0){
        return Card(
          margin:EdgeInsets.all(8),
           child:Container(
            height:double.infinity,
            child:Center(
              child:Text('No attendees data is available. Choose another event!'),
            ),
          ),
        );
      }

      attendeeType.forEach((role,count){
        if (count>0){
          double percentage = (count/total)* 100;
          sections.add(
            PieChartSectionData(
              color: roleColors[role]??Colors.grey,
              value: count.toDouble(),
              title: '$count ${role}\n${percentage.toStringAsFixed(1)}%',
              radius:100,
              titleStyle: const TextStyle(
                fontSize:12,
                fontWeight:FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
      });

    return Card(
      margin: EdgeInsets.all(12),
      child:Container(
        height:double.infinity,
          child: Padding(
            padding:const EdgeInsets.symmetric(vertical:20, horizontal:16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$subtitle - $total attendees'),
                  leading: const Icon(Icons.analytics, color: Color.fromARGB(255, 118, 157, 123)),
                  ),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace:2,
                        centerSpaceRadius:0,
                        sections: sections
                      )
                    )
                  )
                ]
              ),
          ),
      ),
    );
  }

    Widget _buildMyOrganizedEventsList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events I am Organizing... ',
              style:Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 8),
              StreamBuilder<List<Event>>(
              stream: _eventController.getOrganizerEvents(user?.email!??'NO EMAIL'),
              
              builder: (context, snapshot){
                if (!snapshot.hasData){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final events=snapshot.data!;
                if(events.isEmpty){
                  return ListTile(
                    title: Text("You have not created any events yet!"),
                    dense: true,
                  );
                }
                  return ListView.builder(
                shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event= events[index];
                  return ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(event.name),
                    dense: true,
                    selected: selectedEvent?.id == event.id,
                    selectedTileColor: Colors.grey[200],
                    onTap: () => _updateAttendeeData(event),
                  );
                },
              );
              }
            ) 
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorGraph(Event event){
    if (event.stakeholder.isEmpty){
      return Center (child:
      Text('No one has sponsored this event yet. Market your event to attract more sponsors!'));
    }
     List<MapEntry<String, int>> sortedSponsors = event.stakeholder.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

     int maxContribution = sortedSponsors.first.value;

     return Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        Text(
          'Contributions from Sponsors, in CAD',
          style: TextStyle(fontWeight:FontWeight.bold),
        ),
        SizedBox(height:8),
        Expanded(
          child: 
          BarChart(
            BarChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false,),
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxContribution*1.5),
              barTouchData: BarTouchData(
                enabled: true,
              ),
              titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < sortedSponsors.length) {
                      String email = sortedSponsors[index].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Transform.rotate(
                          angle: -320,
                          child: Text(
                            email,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }
                    return Text('');
                  },
                  reservedSize: 40,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                  reservedSize: 35,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
              borderData:FlBorderData(
                show:false,
              ),
              barGroups: List.generate(
                sortedSponsors.length,
                (index)=> BarChartGroupData(
                  x:index,
                  barRods:[
                    BarChartRodData(
                    toY: sortedSponsors[index].value.toDouble(),
                    color: Colors.red,
                       gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 235, 246, 236),Color(0xFFCBDBCD)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width:30,
                    borderRadius:BorderRadius.vertical(top:Radius.circular(6)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
     );
  }
}