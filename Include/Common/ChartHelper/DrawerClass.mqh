//+------------------------------------------------------------------+
//|                                                         aaaa.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link "https://www.metaquotes.net"
//|                                                                  |
//+------------------------------------------------------------------+

#include ".\DrawerComponents\RectangleClass.mqh";
#include ".\DrawerComponents\TextClass.mqh";
#include ".\DrawerComponents\LineClass.mqh";
#include ".\DrawerComponents\LabelClass.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Drawer

  {
protected:
   string            ModuleName;
   long              chartId;
   int               objectId;
   void              ChangeTextEmptyPoint(datetime &time,double &price);
   string            GetName(datetime time,double price,string type);
public:

   RectangleClass   *Rectangle;
   LineClass        *Line;
   TextClass        *Text;
   LabelClass       *Label;

   void ~Drawer()
     {
      delete Rectangle;
      delete Line;
      delete Text;
      delete Label;
     };
   static void       DeleteObjectByNameContains(string _name,long chartId=EMPTY,int type=EMPTY);
   void              Drawer(long chartId,string parentModuleName);
   void              ClearAll();
   void              ClearAll(string parentModuleName);
   bool              ArrowCreate(datetime time,
                                 double price,
                                 ENUM_ORDER_TYPE signalDirection,
                                 const long chart_ID,// chart's ID
                                 const int sub_window,// subwindow index
                                 // anchor point time
                                 int width);
   bool              SignalCreate(datetime time,
                                  double price,
                                  const long chart_ID,// chart's ID
                                  const int sub_window,// subwindow index
                                  int width,
                                  color signalColor);
   bool              SignalCreate(datetime time,
                                  double price,
                                  ENUM_ARROW_ANCHOR anchor,
                                  const long chart_ID,// chart's ID
                                  const int sub_window,// subwindow index
                                  int width,
                                  color signalColor);
   bool              ArrowCreate(int index,ENUM_ORDER_TYPE signalDirection);

   string            LabelCreate(const int               x,// X coordinate
                                 const int               y,// Y coordinate
                                 const string            text,// text
                                 const color             clr,// color
                                 const int               sub_window,// subwindow index
                                 const ENUM_BASE_CORNER  corner,// chart corner for anchoring
                                 const string            font,// font
                                 const int               font_size,// font size
                                 const double            angle,// text slope
                                 const ENUM_ANCHOR_POINT anchor,// anchor type
                                 const bool              back,               // in the background
                                 const bool              selection,          // highlight to move
                                 const bool              hidden,// hidden in the object list
                                 const long              z_order);               // priority for mouse click

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Drawer::Drawer(long _chartId=0,string parentModuleName="")
  {
   ModuleName="DC"+parentModuleName;
   objectId=0;
   chartId = _chartId;

   Rectangle=new RectangleClass(ModuleName,chartId);
   Line=new LineClass(ModuleName,chartId);
   Text=new TextClass(ModuleName, chartId);
   Label=new LabelClass(ModuleName,chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Drawer::ClearAll(string parentModuleName)
  {
   int obj_total=ObjectsTotal();
   for(int i=obj_total-1; i>=0; i--)
     {
      string label=ObjectName(i);

      int labelIndex=StringFind(label,parentModuleName);

      if(labelIndex==0)
        {
         ObjectDelete(label);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Drawer::ClearAll()
  {
   this.ClearAll(ModuleName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void Drawer::DeleteObjectByNameContains(string _name,long chartId=EMPTY,int type=EMPTY)
  {
   int obj_total=ObjectsTotal(type);
   for(int i=obj_total-1; i>=0; i--)
     {
      string label=ObjectName(i);

      int labelIndex=StringFind(label,_name);

      if(labelIndex>-1)
        {
         if(chartId==EMPTY)
            ObjectDelete(label);
         else
            ObjectDelete(chartId,_name);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Drawer::GetName(datetime time,double price,string type="NONE")
  {
//--- set anchor point coordinates if they are not set
   ChangeTextEmptyPoint(time,price);
   string name=StringSubstr(StringFormat("%s%s (X%s)(Y%.3f) %d%d%d",ModuleName,type,TimeToStr(time),price,rand(),rand(),rand()),0,63);

   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Drawer::ArrowCreate(int index,ENUM_ORDER_TYPE signalDirection)
  {
   double price;

   if(signalDirection==OP_BUY)
      price=Low[index];
   else
      price=High[index];

   return this.ArrowCreate(Time[index], price, signalDirection);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Drawer::ArrowCreate(datetime time,// anchor point time
                         double price,
                         ENUM_ORDER_TYPE signalDirection=EMPTY,
                         const long chart_ID=0,// chart's ID
                         const int sub_window=0,// subwindow index
                         int width=2)
  {
//--- set anchor point coordinates if they are not set
   string name=this.GetName(time,price,"Arrow-"+EnumToString(signalDirection));

//--- reset the error value
   ResetLastError();

   int finalIcon=EMPTY;
   color finalColor=EMPTY;
   ENUM_ARROW_ANCHOR anchorPosition=ANCHOR_TOP; // anchor type

   if(signalDirection==OP_BUY)
     {
      finalIcon=233;
      finalColor=clrCyan;
      anchorPosition=ANCHOR_TOP;
     }
   else if(signalDirection==OP_SELL)
     {
      finalIcon=234;
      finalColor=clrLimeGreen;
      anchorPosition=ANCHOR_BOTTOM;
     }

//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return (false);
     }
//--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,finalColor);
//--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,finalIcon);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchorPosition);
   objectId++;
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Drawer::SignalCreate(datetime time,// anchor point time
                          double price,
                          const long chart_ID=0,// chart's ID
                          const int sub_window=0,// subwindow index
                          int width=5,
                          color signalColor=clrCyan)
  {
//--- set anchor point coordinates if they are not set
   string name=this.GetName(time,price,"Signal");

//--- reset the error value
   ResetLastError();

   int finalIcon=158;
   color finalColor=signalColor;
//ENUM_ARROW_ANCHOR anchorPosition=ANCHOR_TOP; // anchor type

//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return (false);
     }
//--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,finalColor);
//--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,finalIcon);
//--- set anchor type
//ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchorPosition);
   objectId++;
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Drawer::SignalCreate(datetime time,// anchor point time
                          double price,
                          ENUM_ARROW_ANCHOR anchor,
                          const long chart_ID=0,// chart's ID
                          const int sub_window=0,// subwindow index
                          int width=5,
                          color signalColor=clrCyan)
  {
//--- set anchor point coordinates if they are not set
   string name=this.GetName(time,price,"Signal");

//--- reset the error value
   ResetLastError();

   int finalIcon=158;
   color finalColor=signalColor;
//ENUM_ARROW_ANCHOR anchorPosition=ANCHOR_TOP; // anchor type

//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return (false);
     }
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the arrow's size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- set the arrow color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,finalColor);
//--- set the arrow code
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,finalIcon);
//--- set anchor type
//ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchorPosition);
   objectId++;
//--- successful execution
   return (true);
  }
//+------------------------------------------------------------------+

void Drawer::ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+

string Drawer::LabelCreate(
                           const int               x=0,                      // X coordinate
                           const int               y=0,                      // Y coordinate
                           const string            text="Testing Label",// text
                           const color             clr=clrCyan,// color
                           const int               sub_window=0,             // subwindow index
                           const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                           const string            font="Arial",             // font
                           const int               font_size=10,             // font size
                           const double            angle=0.0,                // text slope
                           const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                           const bool              back=false,               // in the background
                           const bool              selection=false,          // highlight to move
                           const bool              hidden=true,              // hidden in the object list
                           const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
   string name=this.GetName(x,y,"Label");
//--- create a text label
   long chart_ID=chartId;
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      int lastError=GetLastError();
      switch(lastError)
        {
         case 4200:
           {
            Print(__FUNCTION__,": failed to create label name: ",name);
            break;
           }
         default:
           {
            Print(__FUNCTION__,
                  ": failed to create text label! Error code = ",lastError);
            break;
           }
        }

      return "";
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
