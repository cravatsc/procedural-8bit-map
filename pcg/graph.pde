import java.util.List;

class Node<T>{
  T value;
  List<Edge<T>> out;
  List<Edge<T>> in;
  
  Node(T value){
    this.value = value;
    this.out = new ArrayList();
    this.in = new ArrayList();
  }
  
  void edgeTo(Node<T> destination, float weight){
    Edge<T> edge = new Edge<T>(this, destination, weight);
    this.out.add(edge);
    destination.in.add(edge);
  }
}

class Edge<T>{
  Node<T> start;
  Node<T> end;
  float weight; //weight will be the alt of the end node (could also consider the inverse (1 - diff) of the difference in nodes, this giving the largest alt change as the min weight)

  Edge(Node<T> start, Node<T> end, float weight){
    this.start = start;
    this.end = end;
    this.weight = weight;
  }

}
