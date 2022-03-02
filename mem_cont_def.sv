package mem_cont_defs;

`define MAX 1000

parameter tRP = 24,tRCD = 24,tWR = 20,tRTP = 12,tCCD_L = 8,V = 1,R = 0;

integer fileRead,fileWr;
integer fileScan;
bit [17:0] row;
bit [7:0] column;
bit [1:0] bank;
bit [1:0] bankGroup;
bit [3:0] mode;
logic [8*`MAX:0] temp;

typedef struct packed{
	int QsimulationTime;
	int QclockCycles;
	bit [3:0] Qmode;
	bit [35:0] Qaddress;
}QValObj;
QValObj QVal;

logic clk;
logic[47:0] QueueIn[$:15];
integer unsigned simTime;
logic QueueData;
logic [47:0] popedVar;
integer startClkCycle;
string filename,filenameO;
integer unsigned cpu_time;
int cntr = 0;

typedef enum bit[1:0]{
	PRE=2'b00,
	ACT=2'b01,
	RD=2'b10,
	WR=2'b11
}dramCmd;
dramCmd dram_fl;

int tActivate, tPrecharge, tRead, tWrite;

int i = 0;

int bBgCmd[15:0][1:0];
int flagFirst,prevRd,prevWr,flagCmdExec=0;

endpackage: mem_cont_defs
