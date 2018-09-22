/*
  Linked List Exercise
  Insert, Push and Append methods for linked lists
  (Simple Linked List)
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NO_COLOR -1

// Node struct definition
typedef struct stNode
{
  int data;
  struct stNode *next;
}Node, *hNode;

// Prints backward all nodes in the list
void printbackward(hNode node)
{
  if (node == NULL) return; 

  printbackward(node->next);
  printf("%d ",node->data);
}

// Prints all nodes in the list
void printList(hNode node, int color_index)
{
  int i = 0;

  while (node != NULL) {

    if (color_index == i)
      printf("\e[31;5;1m%d\e[0m ", node->data);
    else
      printf("%d ", node->data);
    
    node = node->next;
    i++;
  }
  putchar('\n');
  
}

// Push a new node to list
void push(hNode *ref, int data)
{
  hNode new_node = (hNode)malloc(sizeof(Node));
  new_node->data = data;
  new_node->next = (*ref);

  (*ref) = new_node;
}

// Append a new node to list
void append(hNode *ref, int data)
{
  hNode new_node = (hNode)malloc(sizeof(Node));
  hNode last_node = *ref;

  if(*ref == NULL)
  {
    *ref = new_node;
    return;
  }

  new_node->data = data;
  new_node->next = NULL;
  
  while (last_node->next != NULL)
  {
    last_node = last_node->next;
  }

  last_node->next = new_node;
}

// Insert a node to list after prev_node passed as parameter
void insertAfter(hNode prev_node, int data)
{
  if(prev_node == NULL)
  {
    printf("The given previous node cannot be NULL.\n");
    return;
  }
  
  hNode new_node = (hNode)malloc(sizeof(Node));
  new_node->data = data;
  new_node->next = prev_node->next;
  prev_node->next = new_node;
}

int main(void)
{

  hNode head, second, third, fourth, fifth, last;

  // allocate 3 nodes in the heap
  head      = (hNode)malloc(sizeof(Node));
  second    = (hNode)malloc(sizeof(Node));
  third     = (hNode)malloc(sizeof(Node));
  fourth    = (hNode)malloc(sizeof(Node));
  fifth     = (hNode)malloc(sizeof(Node));
  last      = (hNode)malloc(sizeof(Node));
  
  head->data    = 1;
  head->next    = second;                       // link first node with second

  second->data  = 2;
  second->next  = third;                        // link second node with third

  third->data   = 3;
  third->next   = fourth;

  fourth->data  = 4;
  fourth->next  = fifth;

  fifth->data   = 6;
  fifth->next   = last;

  last->data    = 7;
  last->next    = NULL;
  
  printf("Initial...\n");
  printList(head, NO_COLOR);

  // test inserting node
  insertAfter(fourth, 5);
  printf("\nAfter \e[;4;1minserting\e[0m new data to list...\n");
  printList(head, 4);

  //test pushing node
  push(&head, 0);
  printf("\nAfter \e[;4;1mpushing\e[0m new data to list...\n");
  printList(head, 0);

  //test appending node
  append(&head, 8);
  printf("\nAfter \e[;4;1mappending\e[0m new data to list...\n");
  printList(head, 8);

  printf("\nPrinting nodes in decending order...\n");
  printbackward(head);
  puts("");
  
  // free memory 
  free(head);
  free(second);
  free(third);
  free(fourth);
  free(fifth);
  free(last);

  return 0;
}
