module FSM(loadAFromRam, loadBFromRam, ramARecord, ramBRecord, toggles, clk, stateOut);
    input [17:0] toggles;
    // input [3:0] KEY; YOU DONT END UP USING THIS :(((((    - Alright :(((((      - Okie dokie then :)))))
	input clk;
	
    output reg loadAFromRam;
	output reg loadBFromRam;
	output reg ramARecord;
	output reg ramBRecord;
	output [3:0] stateOut;

    wire playAFromRamW, playBFromRamW, playBothFromRamW, recordToAW, recordToBW;
	reg [7:0] stateInfo;

    reg [2:0] Y_Q, Y_D; // y_Q represents current state, Y_D represents next state
	// reg current_state, next_state; (Probably not using this, use Y_Q and Y_D above)

    assign stateOut[0] = loadAFromRam;
    assign stateOut[1] = loadBFromRam;
    assign stateOut[2] = ramARecord;
    assign stateOut[3] = ramBRecord;

    localparam freePlay = 3'b000, recordToA = 3'b110, recordToB = 3'b100, playAFromRam = 3'b001,
			playBFromRam = 3'b011;// playBothFromRam = 3'b111;

    assign playAFromRamW = toggles[17];
    assign playBFromRamW = toggles[16];
    assign recordToAW = toggles[1];
    assign recordToBW = toggles[0];

    //State table
    //The state table should only contain the logic for state transitions
    //Do not mix in any output logic. The output logic should be handled separately.
    //This will make it easier to read, modify and debug the code.
    always@(*)
    begin: state_table
        case (Y_Q)
	    // Turn on any of the state switch to jump from the freePlay to any other state
            freePlay: begin
//		if (playAFromRamW && playBFromRamW) Y_D <= playBothFromRam;
		if (playAFromRamW) Y_D <= playAFromRam;
		else if (playBFromRamW) Y_D <= playBFromRam;
		else if (recordToAW) Y_D <= recordToA;
		else if (recordToBW) Y_D <= recordToB;
		else Y_D <= Y_Q;
	    end
				
            playAFromRamW: begin
		if (!playAFromRamW) Y_D <= freePlay;
		else Y_D <= playAFromRam;
	    end
				
            playBFromRamW: begin
		if (!playBFromRamW) Y_D <= freePlay;
		else Y_D <= playBFromRam;
	   end
				
			// @Moe: The case below could result in replay of a piece of record when one of the two play from record switch is turned off
//			playBothFromRamW: begin
//					if (!playAFromRamW && playBFromRamW) Y_D <= playBFromRam;
//					else if (playAFromRamW && !playBFromRamW) Y_D <= playAFromRam;
//					else if (!playAFromRamW && !playBFromRamW) Y_D <= freePlay;
//					else Y_D <= playBothFromRam;
//				end
				
            recordToAW: begin
		if (!recordToAW) Y_D <= freePlay;
		else Y_D <= recordToAW;
	    end
				
	    recordToBW: begin
		if (!recordToBW) Y_D <= freePlay;
		else Y_D <= recordToBW;
	    end
				
            default: Y_D = freePlay;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        // By default make all our signals 0
        loadAFromRam = 1'b0;
        loadBFromRam = 1'b0;
        ramARecord = 1'b0;
		ramBRecord = 1'b0;

        case (Y_Q)
            freePlay: begin
		//pass
            end
			
            playAFromRam: begin
                loadAFromRam = 1'b1;
            end

            playBFromRam: begin
                loadBFromRam = 1'b1;
            end

//            playBothFromRam: begin
//                loadAFromRam = 1'b1;
//				loadBFromRam = 1'b1;
//            end

            recordToA: begin
		ramARecord = 1'b1;
            end
			
            recordToB: begin
		ramBRecord = 1'b1;
            end			

	endcase
    end
	
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        Y_Q <= Y_D;
    end

endmodule
