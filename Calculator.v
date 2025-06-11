module HADD(x,y,S,C);
input  x,y;
output  S,C;
assign S= x^y;
assign C=x&y; 
endmodule

module FADD(x,y,cin,sum,cout); //FullAdder using HalfAdder Bit by Bit
input   cin,x,y;
output  sum,cout;
wire  w1,w2,w3;
HADD H1(x,y,w1,w2);
HADD H2(w1,cin,sum,w3);
assign cout=w2|w3;
endmodule



module ToEightBitExtender(in_data,sign,out_data); //Take any Size Bit and change it to it 8 Bit Length and if its negative change it to 2nd complement
input [7:0] in_data;
input  sign;
output reg [7:0] out_data;
integer i;
always @(*) begin
if(in_data[7]==0|in_data[7]==1) out_data=in_data;
   else begin
 casez (in_data)
        8'b1???????: out_data = in_data;                     
        8'b01??????: out_data = {in_data[6:0], 1'b0};        
        8'b001?????: out_data = {in_data[5:0], 2'b0};         
        8'b0001????: out_data = {in_data[4:0], 3'b0};         
        8'b00001???: out_data = {in_data[3:0], 4'b0};        
        8'b000001??: out_data = {in_data[2:0], 5'b0};        
        8'b0000001?: out_data = {in_data[1:0], 6'b0};         
        8'b00000001: out_data = {in_data[0], 7'b0};          
        default: out_data = 8'b0;                             
  endcase
    for (i = 0; i < 8; i = i + 1) begin
        if (out_data[i] === 1'bz)
            out_data[i] = 1'b0;  
    end
end
if (in_data==8'b0) out_data=out_data;
else if(~sign) out_data=~out_data+1;
end
endmodule



module OperatorPlus(ResNum,InpNum,ResSign,InpSign,res,sign_out); //Takes Num1 As 2 Bit and Num2(should be Accumulated Result) as 8 bit Length and their signs and returns Value and Sign Of result
input [1:0] InpNum;
input [7:0] ResNum;
input ResSign,InpSign;
output [7:0] res;
output sign_out;
wire cout;
wire [7:0] ToNum1,ToNum2,temp_res;
wire [6:0] c;
ToEightBitExtender v1(ResNum,ResSign,ToNum1);
ToEightBitExtender v2(InpNum,InpSign,ToNum2);
FADD f1(ToNum1[0],ToNum2[0],1'b0,temp_res[0],c[0]);
FADD f2(ToNum1[1],ToNum2[1],c[0],temp_res[1],c[1]);
FADD f3(ToNum1[2],ToNum2[2],c[1],temp_res[2],c[2]);
FADD f4(ToNum1[3],ToNum2[3],c[2],temp_res[3],c[3]);
FADD f5(ToNum1[4],ToNum2[4],c[3],temp_res[4],c[4]); 
FADD f6(ToNum1[5],ToNum2[5],c[4],temp_res[5],c[5]);
FADD f7(ToNum1[6],ToNum2[6],c[5],temp_res[6],c[6]);
FADD f8(ToNum1[7],ToNum2[7],c[6],temp_res[7],cout);
assign {res,sign_out}=(InpSign==1&ResSign==1)? {temp_res,1'b1}:(((InpSign==0&ResSign==1)|(InpSign==1&ResSign==0))&cout==0&InpNum!=2'b0&ResNum!=8'b0)?{~temp_res+1'b1,1'b0} :(((InpSign==0&ResSign==1)|(InpSign==1&ResSign==0))&cout==1&InpNum!=2'b0&ResNum!=8'b0)?{temp_res,1'b1}:(InpSign==0&ResSign==0)? {~temp_res+1'b1,1'b0}:(((InpSign==0&ResSign==1)|(InpSign==1&ResSign==0))&InpNum==2'b0)?((ResSign==0)?{~temp_res+1'b1,1'b0}:{temp_res,1'b1}):(ResNum==8'b0)? ((InpSign==0)?{~temp_res+1'b1,1'b0}:{temp_res,1'b1}) :{8'b0,1'b1}; 
endmodule


module OperatorMinus(ResNum,InpNum,ResSign,InpSign,res,sign_out);
input [1:0] InpNum;
input [7:0] ResNum;
input InpSign,ResSign;
output [7:0] res;
output sign_out;
reg MSign1;
always @(*) begin
    if(ResSign==1&InpSign==1&InpNum==2'b0) MSign1=0;
    else MSign1=InpSign;
end
OperatorPlus p(ResNum,InpNum,ResSign,~MSign1,res,sign_out);
endmodule



module binary_to_bcd (binary_in,units,tens,hundreds);
    input [7:0] binary_in;  
    output reg [3:0] units;  
    output reg [3:0] tens;   
    output reg [3:0] hundreds ;
    reg [19:0] shift_register; 
    integer i;

    always @(*) begin
        
        shift_register = 20'b0;
        shift_register[7:0] = binary_in; 

       
        for (i = 0; i < 8; i = i + 1) begin
            if (shift_register[19:16] >= 5)
                shift_register[19:16] = shift_register[19:16] + 3; 
            if (shift_register[15:12] >= 5)
                shift_register[15:12] = shift_register[15:12] + 3; 
            if (shift_register[11:8] >= 5)
                shift_register[11:8] = shift_register[11:8] + 3; 

            shift_register = shift_register << 1;
        end

        
        hundreds = shift_register[19:16];
        tens = shift_register[15:12];
        units = shift_register[11:8];
    end
endmodule


module OperatorMultiply(a,b,sign1,sign2,p,sign_out);
    input [1:0] a;        
    input [6:0] b;         
    input sign1,sign2;           
    output [7:0] p;       
    output sign_out;

    wire [7:0] ToNum2; 
    wire [7:0] mo, me;
    wire [8:0] c;          
   
    ToEightBitExtender E2 (
        .in_data(b),
        .sign(1'b1),
        .out_data(ToNum2)
    );

   
    assign mo = ToNum2 & {8{a[0]}};            
    assign me = (ToNum2 & {8{a[1]}}) << 1;     

    FADD F0 (
        .x(mo[0]),
        .y(me[0]),
        .cin(1'b0),
        .sum(p[0]),
        .cout(c[0])
    );

    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin : FADD_loop
            FADD F1 (
                .x(mo[i]),   
                .y(me[i]),    
                .cin(c[i-1]), 
                .sum(p[i]),      
                .cout(c[i])    
            );
        end
    endgenerate

    assign sign_out = (a==2'b0 | b==7'b0)? (1'b1) : ~(sign1 ^ sign2);

endmodule



module OperatorDivision (
    input [7:0] Num,        
    input [1:0] Den, 
    input NumSign,
    input DenSign,      
    output reg [7:0] Division,
    output reg SignOut,
    output reg ZeroFlag 
);
    reg [8:0] Remainder;    
    reg [15:0] N;
    reg[7:0] TempDem;         
    reg [7:0] Diff;
    integer i;   
    wire [7:0]ToNum; 
    ToEightBitExtender T1(Num,1'b1,ToNum);
    always @(*) begin
        N = {8'b0,ToNum[7:0]};
        TempDem={6'b0,Den[1:0]};     
        SignOut= (Num==7'b0 | Den==2'b0) ? 1'b1 :~(NumSign^DenSign);  
        if (Den == 2'b00) begin
            Division = 8'b0;
            ZeroFlag = 1'b1;
        end else begin
          ZeroFlag = 1'b0; end
          
            for (i = 7; i >= 0; i = i - 1) begin
             N = N << 1;  
            Diff=N[15:8]-TempDem[7:0];
                if (Diff[7]==1'b1) begin
                    Division[i] = 1'b0; 
                end else begin
                    Division[i] = 1'b1;
                     N[15:8]=Diff; 
                end
            end
    end
endmodule




module Manager (
    input [1:0] num1,  
    input [7:0] num2, 
    input sign1, sign2,
    input  [1:0]operation_select,
    output [7:0] result, 
    output sign_out, 
    output reg ZeroFlag
);

    wire [7:0] add_res, sub_res,mul_res,div_res;
    wire add_sign, sub_sign,mul_sign,div_sign;

    
    OperatorPlus adder (num2,num1,sign2,sign1,add_res,add_sign);

    OperatorMinus subtractor (num2,num1,sign2,sign1,sub_res,sub_sign);

    OperatorMultiply multiplier (
        .a(num1),
        .b(num2),
        .sign1(sign1),
        .sign2(sign2),
        .p(mul_res),
        .sign_out(mul_sign)
    );
OperatorDivision Div( num2,num1,sign2,sign1,div_res,div_sign);
   always@(*)begin
     if(operation_select==2'b10&num1==0 ) ZeroFlag=1'b1;
    else ZeroFlag=1'b0;
    end
    assign result = (operation_select == 2'b00) ? add_res :
                    (operation_select == 2'b01) ? sub_res : (operation_select == 2'b11)?
                     mul_res : (ZeroFlag==1)? 8'b0 : div_res;
                   
                  

    assign sign_out = (operation_select == 2'b00) ? add_sign :
                      (operation_select == 2'b01) ? sub_sign :
                      (operation_select == 2'b11) ? mul_sign : div_sign;
                      

endmodule


module seven_segment (
    input [3:0] inp,
    output reg [6:0] out 
);
    always @(*) begin
        case (inp)
           4'b0000: out=7'b1000000;
           4'b0001: out=7'b1111001;
           4'b0010: out=7'b0100100;
           4'b0011: out=7'b0110000;
           4'b0100: out=7'b0011001;
           4'b0101: out=7'b0010010;
           4'b0110: out=7'b0000010;
           4'b0111: out=7'b1111000;
           4'b1000: out=7'b0000000;
           4'b1001: out=7'b0010000;
           default: out=7'b1000000;
        endcase
    end

endmodule

module seven_segment_Sign (
    input inp,  
    output reg [6:0] out 
);
    always @(*) begin
        if (inp == 1'b0) out = 7'b0111111;
        else out = 7'b1111111;
    end

endmodule


module seven_segment_controller (
    input [7:0] final_result,   
    input [1:0] current_number, 
    output [6:0] seg1,  
    output [6:0] seg2,  
    output [6:0] seg3,  
    output [6:0] seg4  
);
    wire [3:0] result_units, result_tens, result_hundreds;
    wire [7:0] ToNum;
    reg [3:0] ToInp;
    
    always @(*)
    begin
        ToInp = {2'b0, current_number};
    end

    ToEightBitExtender T1 (final_result,1'b1,ToNum);
    
    binary_to_bcd bcd_converter (
        .binary_in(ToNum),
        .units(result_units),
        .tens(result_tens),
        .hundreds(result_hundreds)
    );

    seven_segment display1 (.inp(result_units), .out(seg1));
    seven_segment display2 (.inp(result_tens), .out(seg2));
    seven_segment display3 (.inp(result_hundreds), .out(seg3));
    seven_segment display4 (.inp(ToInp), .out(seg4));

endmodule




module Calculator (
    input clk,
    input [1:0] InpNum,        
    input InpSign,            
    input [1:0] OP,            
    output wire [6:0] InpSeg,  
    output reg [6:0] ResSegUnits,  
    output reg [6:0] ResSegTens,  
    output reg [6:0] ResSegHundreds,
    output wire [6:0]SignSeg,
	 output reg [6:0]ResSignSeg,
    output reg ZeroFlag,
    output reg SignFlag,
    output reg zeroResult
);
    reg[1:0] PreOP=2'b00;
    reg[7:0] num2;     
    reg sign2;          
    wire[7:0] manager_result; 
    wire manager_sign_out;     
    wire[6:0] UnitSeg,TenSeg,HundSeg; 
    wire Zero_Flag;
	 wire [6:0] Res_Sign_seg;
    integer counter=0;
    Manager manager_inst (
        .num1(InpNum),
        .num2(num2),
        .sign1(InpSign),
        .sign2(sign2),
        .operation_select(PreOP),
        .result(manager_result),
        .sign_out(manager_sign_out),
        .ZeroFlag(Zero_Flag)
    );
seven_segment_controller ssc (
        .final_result(manager_result),
        .current_number(InpNum),
        .seg1(UnitSeg),
        .seg2(TenSeg),
        .seg3(HundSeg),
        .seg4(InpSeg)
    );

    seven_segment_Sign SS(
        .inp(InpSign),
        .out(SignSeg)
    );
	 
	 seven_segment_Sign CC(
        .inp(manager_sign_out),
        .out(Res_Sign_seg)
    );

   always @(posedge clk) begin
        if(counter==0)begin SignFlag=InpSign;  PreOP=OP; num2=InpNum; sign2=InpSign; counter=counter+1; end
        else if (counter < 4)
        begin           
            ResSegUnits<=UnitSeg;
            ResSegTens<=TenSeg;
            ResSegHundreds<=HundSeg;
            SignFlag<=manager_sign_out;
            num2 <= manager_result;        
            sign2 <= manager_sign_out;  
            PreOP<=OP;   
            ZeroFlag<=Zero_Flag;
				ResSignSeg<=Res_Sign_seg;
            if(num2==8'b0) zeroResult=1; else zeroResult=0;
            counter <= counter + 1;         
        end 
        else if (counter == 4)
        begin
            ResSegUnits<=UnitSeg;
            ResSegTens<=TenSeg;
            ResSegHundreds<=HundSeg;
            SignFlag<=manager_sign_out;
            ZeroFlag<=Zero_Flag;
				ResSignSeg<=Res_Sign_seg;
             if(num2==8'b0) zeroResult=1; else zeroResult=0;
            counter <= counter+1;
        end
   end


endmodule
