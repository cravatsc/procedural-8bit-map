import java.util.PriorityQueue;
import java.util.HashMap;
import java.util.Collections;

interface GraphSearch<T>{
  void reset(Node<T> start, Node<T> goal);
  List<Edge<T>> findPath();
}

interface Heuristic<T> {
  float value(T start, T goal);
}

class Manhattan implements Heuristic<GridPoint>{
  float value(GridPoint start, GridPoint goal){
    return abs(goal.x - start.x) + abs(goal.y - start.y);
  }
}

class AStarTag<T> implements Comparable<AStarTag<T>>{
  Node<T> node;
  float cfs;
  float ctg;
  Edge<T> edge;
  
  AStarTag(Node<T> node, float cfs, float ctg, Edge<T> edge){
    this.node = node;
    //cost from start
    this.cfs = cfs;
    //cost to goal = heuristic + CFS
    this.ctg = ctg;
    //connection - reference to the incoming edge
    this.edge = edge;
  }
  
  int compareTo(AStarTag<T> o){
    if(this.ctg < o.ctg)
      return -1;
    else if(this.ctg > o.ctg)
      return 1;
    else
      return 0;
  }
}

class AStar<T> implements GraphSearch<T>{
  Node<T> start;
  Node<T> goal;
  
  HashMap<Node<T>, AStarTag<T>> tags;
  
  PriorityQueue<AStarTag<T>> openSet;
  
  Heuristic<T> heuristic;
  
  AStar(Heuristic<T> heuristic){
    this.heuristic = heuristic;
  }
  
  void reset(Node<T> start, Node<T> goal){
    this.start = start;
    this.goal = goal;
    tags = new HashMap<Node<T>, AStarTag<T>>();
    openSet = new PriorityQueue<AStarTag<T>>();
    
    AStarTag<T> startTag = new AStarTag<T>(start, 0.0f, heuristic.value(start.value, goal.value), null);
    tags.put(start, startTag);
    openSet.add(startTag);
  }

  List<Edge<T>> findPath(){
    //find path
    while(!openSet.isEmpty()){
      AStarTag<T> smallestNode = openSet.poll();
      
      for(Edge<T> edge : smallestNode.node.out){
        float nextCfs = smallestNode.cfs + edge.weight;
        AStarTag<T> nextTag = tags.get(edge.end);
        if(null == nextTag || nextCfs < nextTag.cfs){
          float nextCtg = nextCfs + heuristic.value(edge.end.value, goal.value);
          nextTag = new AStarTag<T>(edge.end, nextCfs, nextCtg, edge);
          tags.put(nextTag.node, nextTag);
          openSet.add(nextTag);
        }   
      }
    }
    
    //loop shortest path and return
    float pathLength = 0;
    List<Edge<T>> path = new ArrayList<Edge<T>>();
    
    AStarTag<T> tag = tags.get(goal);
    if(tag != null){
      while(null != tag.edge){
        path.add(tag.edge);
        pathLength += tag.edge.weight;
        tag = tags.get(tag.edge.start);
      }
      Collections.reverse(path);
      println("Path Length: " + pathLength);
      return path;
    }
    //no path from high to low, no river
    return null;
  }  
}

class DijkstrasTag<T> implements Comparable<DijkstrasTag<T>>{
  Node<T> node;
  float cfs;
  Edge<T> edge;
  
  DijkstrasTag(Node<T> node, float cfs, Edge<T> edge){
    this.node = node;
    //cost so far
    this.cfs = cfs;
    //connection - reference to the incoming edge
    this.edge = edge;
  }
  
  int compareTo(DijkstrasTag<T> o){
    if(this.cfs < o.cfs)
      return -1;
    else if(this.cfs > o.cfs)
      return 1;
    else
      return 0;
  }
}

class Dijkstras<T> implements GraphSearch<T>{
  Node<T> goal;
  Node<T> start;
  
  HashMap<Node<T>, DijkstrasTag<T>> tags;
  
  PriorityQueue<DijkstrasTag<T>> openSet;
  
  void reset(Node<T> start, Node<T> goal){
    this.start = start;
    this.goal = goal;
    tags = new HashMap<Node<T>, DijkstrasTag<T>>();
    openSet = new PriorityQueue<DijkstrasTag<T>>();
    
    DijkstrasTag<T> startTag = new DijkstrasTag<T>(start, 0, null);
    tags.put(start, startTag);
    openSet.add(startTag);    
  }
  
  List<Edge<T>> findPath(){
    while(!openSet.isEmpty()){
      DijkstrasTag<T> smallestNode = openSet.poll();
      for(Edge<T> edge : smallestNode.node.out){
        DijkstrasTag<T> outgoingTag = tags.get(edge.end);
        if(outgoingTag == null){
          outgoingTag = new DijkstrasTag<T>(edge.end, Float.POSITIVE_INFINITY, null);
          tags.put(edge.end, outgoingTag);
          openSet.add(outgoingTag);
        }
        if(outgoingTag.cfs > smallestNode.cfs + edge.weight){
          outgoingTag.cfs = smallestNode.cfs + edge.weight;
          outgoingTag.edge = edge;
        }
      }
    }
    //loop shortest path and return
    float pathLength = 0;
    List<Edge<T>> path = new ArrayList<Edge<T>>();
    
    DijkstrasTag<T> tag = tags.get(goal);
    if(tag != null){
      while(null != tag.edge){
        path.add(tag.edge);
        pathLength += tag.edge.weight;
        tag = tags.get(tag.edge.start);
      }
      Collections.reverse(path);
      println("Path Length: " + pathLength);
      return path;
    }
    //no path from high to low, no river
    
    return null;
  }
}
