module FinalProject (
	input [1:0] key,
	input [9:0] sw,
	input cin,
	output [7:0] hex0, 
	output [7:0] hex1, 
	output [7:0] hex2, 
	output [7:0] hex3, 
	output [7:0] hex4, 
	output [7:0] hex5, 
	output [9:0] led
);

wire cout;
wire [5:0] counter1, counter2, counter3;

reg [15:0] score;

reg [3:0] firstDigit, secondDigit;

wire [3:0] randomNum1, randomNum2, randomNum3;

reg [2:0] life;

//Define lives
life[0] = led[0];
life[1] = led[1];
life[2] = led[2];

wire [7:0] binary;

ClockDivider clock(cin, cout);

Counter counterLevel1(cout, key[0], 2'b01, counter1); //counter for level 1
Counter counterLevel2(cout, key[0], 2'b10, counter2); //counter for level 2
Counter counterLevel3(cout, key[0], 2'b11, counter3); //counter for level 3

RandomNumGenerator #(3) randGen1(key[0], randomNum1); //random number generates decimal from 0-9 (used for all levels, with a condition) 
Random0to5 #(6) randGen2(key[0], randomNum2); // generates a random number from 0-5 (this is used for level 3 when the third digit is 2, max we can go is 255)
Random2or1 #(2) randGen3(key[0], randomNum3); //for level 3, generates a number from 1-2 (this is the third digit for level 3)

//countdown for counter - general, fix them up for each level
// we can have a register called "counter" to choose between the levels - stuck at counter1 for now

always @(counter1) begin
	firstDigit = counter1 % 10;
	secondDigit = (counter1 - (counter1 % 10)) / 10;
end

// for random number
sevenSegDisplay(randomNum1%10, hex0);
//sevenSegDisplay(randomNum2%10, hex1);
//sevenSegDisplay(randomNum3%10, hex2);

//YOU WIN
//SevenSegLetters (.letter(4'b0000), .sevenSeg(hex4)); //U
//SevenSegLetters (.letter(4'b0101), .sevenSeg(hex2)); //w
//SevenSegLetters (.letter(4'b0110), .sevenSeg(hex1)); //I
//SevenSegLetters (.letter(4'b0111), .sevenSeg(hex0)); //N
//SevenSegLetters (.letter(4'b1111), .sevenSeg(hex3)); //OFF
//SevenSegLetters (.letter(4'b1111), .sevenSeg(hex5)); //OFF

//YOU LOSE
//SevenSegLetters (.letter(4'b0000), .sevenSeg(hex5)); //U
//SevenSegLetters (.letter(4'b0001), .sevenSeg(hex3)); //L
//SevenSegLetters (.letter(4'b0010), .sevenSeg(hex2)); //O
//SevenSegLetters (.letter(4'b0011), .sevenSeg(hex1)); //S
//SevenSegLetters (.letter(4'b0100), .sevenSeg(hex0)); //E
//SevenSegLetters (.letter(4'b1111), .sevenSeg(hex4)); //OFF



Converter decimalToBinary({randomNum1%10 ,randomNum2%10 ,randomNum1%10}, binary);

// for clock down counter
sevenSegDisplay(firstDigit, hex4);
sevenSegDisplay(secondDigit, hex5);

endmodule

//-----------------------------------------

module Counter(
	input clk,
	input reset,
	input [2:0] level,
	output reg [5:0] counter
);

always @(posedge clk or negedge reset) begin
	if (~reset) begin
		case (level)
		2'b01 : counter <= 6'b011110; //30 seconds - level 1
		2'b10 : counter <= 6'b101000; //40 seconds - level 2
		2'b11 : counter <= 6'b110010; //50 seconds - level 3
 		endcase
	end
	else begin
		counter <= counter - 1;
	end
end

endmodule

//-----------------------------------------

module incrementScore(
	input clk,
	input reset,
	input [2:0] level,
	output reg [7:0] score
);

always @(posedge clk or negedge reset) begin
	if(~reset) begin
		case (level)
		2'b01 : score <= score + 100; //increase the score by 100, level 1
		2'b10 : score <= score + 200; //increase the score by 200, level 2
		2'b11 : score <= score + 600; //increase the score by 600, level 3
		endcase
	end
	if(score == 900) begin
	end
end

endmodule

//-----------------------------------------

module SevenSegLetters (
    input [3:0] letter,
    output reg [7:0] sevenSeg
);

    always @* begin
        case (letter)
            4'b0000: sevenSeg = 8'b11000001; // Letter U
            4'b0001: sevenSeg = 8'b11000111; // Letter L
            4'b0010: sevenSeg = 8'b11000000; // Letter O
            4'b0011: sevenSeg = 8'b10010010; // Letter S
            4'b0100: sevenSeg = 8'b10000110; // Letter E
            4'b0101: sevenSeg = 8'b11010101; // Letter W
				4'b0110: sevenSeg = 8'b11111001; // Letter I
				4'b0111: sevenSeg = 8'b11001000; // Letter N
				4'b1111: sevenSeg = 8'b11111111; //Everything Off	
			   //default case for No letters
            default: sevenSeg = 8'b11111111; 
        endcase
    end

endmodule

//-----------------------------------------


module RandomNumGenerator #(parameter N=4) (
input wire reset,
output [3:0] randomOut
);

integer i;
reg [3:0] shiftReg = N;


always @(negedge reset) begin
	if (~reset) begin
		shiftReg <= shiftReg[3] ^ shiftReg[2];
		for (i = 1; i < 4; i=i+1) begin
			shiftReg[i] <= shiftReg[i-1];
		end
	end
end

assign randomOut = shiftReg;

endmodule

//-----------------------------------------

module Random2or1 #(parameter N=4) (
input wire reset,
output [3:0] randomOut
);

integer i;
reg [3:0] shiftReg = N;


always @(negedge reset) begin
	if (~reset) begin
		shiftReg <= shiftReg[3] ^ shiftReg[2];
		for (i = 1; i < 4; i=i+1) begin
			shiftReg[i] <= shiftReg[i-1];
		end
	end
end

assign randomOut = (shiftReg[0]) ? 2'b01 : 2'b10;

endmodule

//-----------------------------------------

module Random0to5 #(parameter N=4) (
input wire reset,
output [2:0] randomOut
);

integer i;
reg [2:0] shiftReg = N;


always @(negedge reset) begin
	if (~reset) begin
		shiftReg <= shiftReg[2] ^ shiftReg[1];
		for (i = 1; i < 3; i=i+1) begin
			shiftReg[i] <= shiftReg[i-1];
		end
	end
end

assign randomOut = (shiftReg == 3'b110 || shiftReg == 3'b111) ? 3'b001 : shiftReg;

endmodule

//-----------------------------------------

module BuzzerSoundEffect1(
    input clk,
    input reset,
    output reg buzzerOut
);

reg [23:0] counter;
reg [3:0] nextMelody;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        nextMelody <= 0;
        buzzerOut <= 0;
    end else begin
        if (counter == 0) begin
            case (nextMelody)
                4'b0000: buzzerOut <= 1;
                4'b0001: buzzerOut <= 0; 
                4'b0010: buzzerOut <= 1;
					 4'b0011: buzzerOut <= 0;
					 4'b0100: buzzerOut <= 1;
					 4'b0101: buzzerOut <= 0;
					 4'b0110: buzzerOut <= 1;
					 4'b0111: buzzerOut <= 0;
					 4'b1000: buzzerOut <= 1;
					 4'b1001: buzzerOut <= 0;
					 4'b1010: buzzerOut <= 1;
					 4'b1011: buzzerOut <= 0;
					 4'b1100: buzzerOut <= 1;
					 4'b1101: buzzerOut <= 0;
					 4'b1110: buzzerOut <= 1;
					 4'b1111: buzzerOut <= 0;
					 4'b1000: nextMelody <= 0;
            endcase
            nextMelody <= nextMelody + 1;
        end
        counter <= counter + 1;
        if (counter == 24'd1000000) counter <= 0;  // frequency
    end
end

endmodule

//-------------------------------------------

module BuzzerSoundEffect2(
    input clk,
    input reset,
    output reg buzzerOut
);

reg [23:0] counter;
reg [3:0] nextMelody;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        nextMelody <= 0;
        buzzerOut <= 0;
    end else begin
        if (counter == 0) begin
            case (nextMelody)
                4'b0000: buzzerOut <= 1;
                4'b0001: buzzerOut <= 0; 
                4'b0010: buzzerOut <= 1;
					 4'b0011: buzzerOut <= 0;
					 4'b0100: buzzerOut <= 1;
					 4'b0101: buzzerOut <= 0;
					 4'b0110: buzzerOut <= 1;
					 4'b0111: buzzerOut <= 0;
					 4'b1000: buzzerOut <= 1;
					 4'b1001: buzzerOut <= 0;
					 4'b1010: buzzerOut <= 1;
					 4'b1011: buzzerOut <= 0;
					 4'b1100: buzzerOut <= 1;
					 4'b1101: buzzerOut <= 0;
					 4'b1110: buzzerOut <= 1;
					 4'b1111: nextMelody <= 0;
            endcase
            nextMelody <= nextMelody + 1;
        end
        counter <= counter + 1;
        if (counter == 24'd250000) counter <= 0;  // frequency
    end
end

endmodule

