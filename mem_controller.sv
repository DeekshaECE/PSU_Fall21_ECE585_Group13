//////////////////////////////////////////////////////////////
// mem_controller.sv - Process DRAM requests
//
// Author:	Deeksha Chandra Shekar (deek@pdx.edu) 
// Date:	09-Dec-2021
//
// Description:
// ------------
// Memory Controller Design
////////////////////////////////////////////////////////////////
import mem_cont_defs::*;

module mem_controller();

function void displayData();
	row = QueueIn[0][35:18];
	column = QueueIn[0][17:10];
	bank = QueueIn[0][9:8];
	bankGroup = QueueIn[0][7:6];
	if($test$plusargs("Enable_Queue_Read"))
		$display("HexAddress format: 0x%h, row = %d, column = %d, bank = %d, bankGroup = %d",QueueIn[0], row, column, bank, bankGroup);
endfunction

function void dataPop();
	popedVar = QueueIn.pop_front();
	if($test$plusargs("Enable_Queue_Read"))
		$displayh("popedVar: %p, popHexAddress:0x%h, popMode:%d, popClockCycle:%d",popedVar, popedVar[35:0], popedVar[39:36], popedVar[47:40]);
	flagCmdExec = 0;
endfunction

function void dataPush(input QValObj QueuePush);
	QueueIn.push_back(QueuePush);
	QueuePush.QsimulationTime = simTime;
endfunction

function void tPrechargeData(input QValObj QPreData);
	if(prevRd == 1)
		cpu_time += tRTP;
	else if(prevWr == 1)
		cpu_time += tWR;
	dram_fl = PRE;
	dram_cmd(dram_fl);
	cpu_time += (tPrecharge*2);
	dram_fl = ACT;
	dram_cmd(dram_fl);
	cpu_time += (tActivate*2);
	if(QPreData.Qmode == 1)
		dram_fl = WR;
	else
		dram_fl = RD;
	dram_cmd(dram_fl);
	while(simTime != cpu_time)
		simTime += 1;
	dataPop();
endfunction

function void tActivateData(input QValObj QActData);
	dram_fl = ACT;
	dram_cmd(dram_fl);
	cpu_time += (tActivate*2);
	if(QActData.Qmode == 1)
		dram_fl = WR;
	else
		dram_fl = RD;
	dram_cmd(dram_fl);
	while(simTime != cpu_time)
		simTime += 1;
	dataPop();
endfunction

function void tRdWrData(input QValObj QRdWrData);
	cpu_time += tCCD_L;
	if(QRdWrData.Qmode == 1)
		dram_fl = WR;
	else 
		dram_fl = RD;
	dram_cmd(dram_fl);
	while(simTime != cpu_time)
		simTime += 1;
	dataPop();
endfunction

function int indexCalc(int bankGroup, int bank);
	case(bankGroup)
		0: i = bank;
		1: i = bank + 4;
		2: i = bank + 8;
		3: i = bank + 12;
	endcase
	return i;
endfunction

function void dram_cmd_execution_pop(input QValObj QueueDram);	
	if(QueueDram.Qmode == 0 || QueueDram.Qmode == 1 || QueueDram.Qmode == 2)begin
		displayData();
		i = indexCalc(bankGroup, bank);
		if(bBgCmd[i][V] == 0) begin
			tActivateData(QueueDram);
			bBgCmd[i][V] = 1;
			bBgCmd[i][R] = row;
		end
		else begin
			if(bBgCmd[i][R] == row)begin
				tRdWrData(QueueDram);
			end
			else begin
				bBgCmd[i][R] = row;
				if((mode == 0 || mode == 2)) begin
					prevRd = 1;
					tPrechargeData(QueueDram);
					prevRd = 0;
				end
				else if(mode == 1) begin
					prevWr = 1;
					tPrechargeData(QueueDram);
					prevWr = 0;
				end
			end
		end
		mode = QueueDram.Qmode;
	end
	else
		$display("Invalid command\n");
endfunction

function void dram_cmd(input dramCmd dram_fl);
	$value$plusargs("OUTPUT_FILE=%s",filenameO);
	fileWr = $fopen(filenameO,"a+");
	case(dram_fl)
		2'b00: begin
			$displayh("Time = %d, %s 0x%h 0x%h", cpu_time, dram_fl.name(), bankGroup, bank);
			$fwrite(fileWr,"%d\t %s\t %d\t %d\n", cpu_time, dram_fl.name(), bankGroup, bank);
		end
		2'b01: begin
			$displayh("Time = %d, %s 0x%h 0x%h %d", cpu_time, dram_fl.name(), bankGroup, bank, row);
			$fwrite(fileWr,"%d\t %s\t %d\t %d\t %d\n", cpu_time, dram_fl.name(), bankGroup, bank, row);
		end
		2'b10,2'b11: begin
			$displayh("Time = %d, %s 0x%h 0x%h %d", cpu_time, dram_fl.name(), bankGroup, bank, column);
			$fwrite(fileWr,"%d\t %s\t %d\t %d\t %d\n", cpu_time, dram_fl.name(), bankGroup, bank, column);
		end
	endcase
	$fclose(fileWr);
endfunction

initial begin
	simTime = 0;
	cpu_time = 0;
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	assign tActivate = tRCD;
	assign tPrecharge = tRP;

	bBgCmd[i][R] = -1;
	bBgCmd[i][V] = 0;

	if(!$value$plusargs("INPUT_FILE=%s",filename))
		$display("No Input trace file!");
	fileRead = $fopen(filename,"r");
    	if(!fileRead) begin
      		$display("Nothing in Queue!!!\n");
      		$stop;
    	end
end

always@(posedge clk) begin
	fork
		begin
			simTime = simTime + 1;
			if(!$feof(fileRead) && QueueIn.size() < 16) begin
				fileScan = $fgets (temp, fileRead);
				if(fileScan == 0)begin
					$display("File is empty\n");
					$stop;
				end
				fileScan = $sscanf(temp,"%d %d 0x%h\n",QVal.QclockCycles,QVal.Qmode,QVal.Qaddress);
				if(simTime >= QVal.QclockCycles)begin
					$display("data pushed\n");
					dataPush(QVal);
				end
				else if(QueueIn.size == 0) begin
					if(simTime < QVal.QclockCycles) begin
						startClkCycle = QVal.QclockCycles;
						simTime = startClkCycle;
						cpu_time = simTime;
						dataPush(QVal);
					end
				end
			end
			else begin
				if($feof(fileRead))begin
					if(QueueIn.size() == 0)begin
						$stop;
					end
				end
				else begin
					dram_cmd_execution_pop(QVal);
					fileScan = $fgets(temp, fileRead);
					fileScan = $sscanf(temp,"%d %d 0x%h",QVal.QclockCycles,QVal.Qmode,QVal.Qaddress);
					if(simTime >= QVal.QclockCycles)
						dataPush(QVal);
				end
			end
		end
		begin
			if(flagCmdExec == 0 && QueueIn.size != 0)begin
				flagCmdExec = 1;
				dram_cmd_execution_pop(QVal);
				$display("Command Executed..!\n");
			end
		end
	join
end
endmodule
