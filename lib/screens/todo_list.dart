import 'package:flutter/material.dart';
import 'package:todoapp/screens/add_page.dart';
import 'package:todoapp/widget/todo_card.dart';
import 'package:todoapp/service/todo_service.dart';
import 'package:todoapp/utils/snackbar_helper.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
  
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,

      ),

    body: Visibility(
      visible: isLoading,
      child: Center(child: CircularProgressIndicator()),
      replacement: RefreshIndicator(
        onRefresh: fetchTodo,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: Center(
            child: Text('No Todo Item',
            style: Theme.of(context).textTheme.headlineLarge,),
          ),
          child: ListView.builder(
            itemCount: items.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context,index){
            
            final item = items[index] as Map;  
            final id = item['_id'] as String;
            return TodoCard(
            index: index, 
            deleteById: deleteById,
            navigateEdit: navigateToEditPage,
            item: item,
            );
          },),
        ),
      ),
    ),
     

      floatingActionButton: FloatingActionButton.extended(
        onPressed:navigateToAddPage, 
        label: Text("Add Todo")),

    );
  }

    Future<void>navigateToEditPage(Map item) async{

    final route = MaterialPageRoute(
      builder: (context)=> AddTodoPage(todo: item),
      );

    await  Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage()async{

    final route = MaterialPageRoute(
      builder: (context)=> AddTodoPage(),
      );

    await  Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
  
  Future<void> deleteById(String id) async {
  
    final isSuccess = await TodoService.deleteById(id);

    if(isSuccess){
     
      final filtered = items.where((element) => element['_id'] !=id).toList();
      setState(() {
        items = filtered;
      });

    }
    else{

     showErrorMessage(context, message: 'Deletion Failed');

    }

  }

  Future<void> fetchTodo()async{
    final response = await TodoService.fetchTodos();
    
    if(response!= null){
      setState(() {
        items = response;
      });

    }
    else{

      showErrorMessage(context,message:'Something went wrong');
    }


    setState(() {
      
      isLoading = false;
    });
    
  }


}