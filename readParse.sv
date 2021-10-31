//////////////////////////////////////////////////////////////
// readParse.sv - Reading and Parsing a Queue
//
// Author:	Deeksha Chandra Shekar (deek@pdx.edu) 
//		Sneha Nagaiah (nagaiah@pdx.edu)
//		Chandana Narayanamurthy (cn23@pdx.edu)
//		Chrystle Pinto FNU (chrystle@pdx.edu)
// Date:	30-Oct-2021
//
// Description:
// ------------
// Reads a Queue and Displays contents on Enable
////////////////////////////////////////////////////////////////

`define MAX 1000

module readParse();
	integer fileRead;
  	integer fileScan;
	logic [7:0] clockCycles,mode;
  	logic [33:0] address;
	logic [8*`MAX:0] temp;

initial begin
	fileRead = $fopen("queuedHere.txt","r");
    	if(!fileRead) begin
      		$display("Nothing in Queue!!!\n");
      		$stop;
    	end
end

initial begin
	while(!$feof(fileRead)) begin
		fileScan = $fgets (temp, fileRead);
		fileScan = $sscanf(temp,"%d %d 0x%h\n",clockCycles,mode,address);
		if($test$plusargs("Enable_Queue_Read"))
      			$display("Data=%d %d 0x%h\n",clockCycles,mode,address);
	end
	$fclose(fileRead);
end

endmodule
