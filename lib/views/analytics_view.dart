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

    @override
  void initState() {
    super.initState();
        user= FirebaseAuth.instance.currentUser!;
      _profileController= ProfileController(AuthService());
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
                            child: _buildMetricCard('Attendee Participation', '75% Active'),
                          ),
                          Expanded(
                            child:_buildMetricCard('Event Success', '85% Positive Feedback'),
                          )
                        ],
                      ),
                    ),
                  Expanded(
                    flex:1,
                    child: _buildPieChart('Feedback Collected', '120 Responses'), 
                  )
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

    Widget _buildPieChart(String title, String value) {
    return Card(
      margin: EdgeInsets.all(8),
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
                  subtitle: Text(value),
                  leading: const Icon(Icons.analytics, color: Color.fromARGB(255, 118, 157, 123)),
                  ),
                  Expanded(
                    child:PieChart(
                      PieChartData(
                        sectionsSpace:0,
                        centerSpaceRadius:40,
                        sections:[
                          PieChartSectionData(
                            color: Colors.green,
                            value:65,
                            title:"70 green",
                             radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),


                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: 25,
                            title: '25% orange',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: 10,
                            title: '10% red',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ]
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
                  stream: _eventController.getOrganizerEvents(user?.email!??'NOEMAIL'),
                  
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
}