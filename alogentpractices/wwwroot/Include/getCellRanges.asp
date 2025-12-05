 <% 
   function getRangeCells()
       dim cellArray(29,2)
       cellArray(0,0) = "A"
       cellArray(0,1) = "A"
       
       cellArray(1,0) = "B"
       cellArray(1,1) = "B"
       
       cellArray(2,0) = "C" 
       cellArray(2,1) = "C"
       
       cellArray(3,0) = "D"
       cellArray(3,1) = "D" 
       
       cellArray(4,0) = "E"
       cellArray(4,1) = "E"
       
       cellArray(5,0) = "F"
       cellArray(5,1) = "F"
       
       cellArray(6,0) = "G" 
       cellArray(6,1) = "G"
       
       cellArray(7,0) = "H"
       cellArray(7,1) = "H" 
       
       cellArray(8,0) = "I"
       cellArray(8,1) = "I"
       
       cellArray(9,0) = "J"
       cellArray(9,1) = "J"
       
       cellArray(10,0) = "K" 
       cellArray(10,1) = "K"
       
       cellArray(11,0) = "L" 
       cellArray(11,1) = "L"
       
       cellArray(12,0) = "M" 
       cellArray(12,1) = "M"
       
       cellArray(13,0) = "N" 
       cellArray(13,1) = "N"
       
       cellArray(14,0) = "O" 
       cellArray(14,1) = "O"
       
       cellArray(15,0) = "P" 
       cellArray(15,1) = "P"
       
       cellArray(16,0) = "Q" 
       cellArray(16,1) = "Q"
       
       cellArray(17,0) = "R" 
       cellArray(17,1) = "R"
       
       cellArray(18,0) = "S" 
       cellArray(18,1) = "S"
       
       cellArray(19,0) = "T" 
       cellArray(19,1) = "T"
       
       cellArray(20,0) = "U" 
       cellArray(20,1) = "U"
       
       cellArray(21,0) = "V" 
       cellArray(21,1) = "V"
       
       cellArray(22,0) = "W" 
       cellArray(22,1) = "W"
              
       cellArray(23,0) = "X"
       cellArray(23,1) = "X" 
       
       cellArray(24,0) = "Y"
       cellArray(24,1) = "Y"
       
       cellArray(25,0) = "Z"
       cellArray(25,1) = "Z"
       
       cellArray(27,0) = "0"
       cellArray(27,1) = "9"
       
       cellArray(28,0) = "other"
       cellArray(28,1) = "other"

       cellArray(29,0) = "^"
       cellArray(29,1) = "^"
       
       session("rangecells") = cellArray
       
   end function
 %>