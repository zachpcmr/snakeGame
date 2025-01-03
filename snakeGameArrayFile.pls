////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
handleGameboard function
    entry

eatRecent         integer            1,"0"

    if (gameBoardArray[arrayNavigation.row,arrayNavigation.column] == 2)    //snake hit some food
        incr eatRecent
        call snakeEatsFood using foodEaten
        
    endif

    if (gameBoardArray[arrayNavigation.row,arrayNavigation.column] == 1)   //snake hit its tail
        call snakeDiedFromTail
    endif

	if (!initComplete)
		call initialize 
	endif

    call updateArray 

    //this resets every time and is always food atm
    move 2 to gameBoardArray[2,6]      //hard code food @96x96
    call handleSnakeDirection using eatRecent,foodEaten
    
    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
initialize function
	entry

counter           integer            2
    move 0 to gameBoardArray
    move 1 to gameBoardArray[arrayNavigation.row,arrayNavigation.column]  
       
    move 2 to gameBoardArray[2,6]      //hard code food 96x96

        for counter from "0" TO "11" USING "1"
            move 9 to gameBoardArray[0,counter]
            move 9 to gameBoardArray[counter,0]
            move 9 to gameBoardArray[counter,11]
            move 9 to gameBoardArray[11,counter]            
        repeat

	move 1 to initComplete 

	functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
updateArray function 
    entry

pixelSize       const            "48"

// these first two moves are to track where the head USED to be so we can always place a new tail right behind it.
    move headOfSnake.y1 to tailRec.Taily1
    move headOfSnake.x1 to tailRec.Tailx1

    move 1 to  gameBoardArray[arrayNavigation.row,arrayNavigation.column]
    mult arrayNavigation.row by pixelSize, headOfSnake.x1
    mult arrayNavigation.column by pixelSize, headOfSnake.y1
    
    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// deleteTail goes through our picture array and for each instance it move it down one number of the array,
// we do this to mimic a stack, with the oldest tails being low numbers, and the newest tails being high numbers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
deleteTail  function
    entry

tailMinus1      integer     2
counter         integer     2
tailCounterTemp integer     2
foodEatenTemp   integer     2
foodEatenTempMin1 integer   2
    subtract 1 from tailCounter, tailMinus1
    move tailCounter to tailCounterTemp
    
    move foodEaten to foodEatenTemp,foodEatenTempMin1
    subtract 1 from foodEatenTempMin1
        destroy snakeTail(1)

        //TODO:
        // for loop is being weird when dealing with a third tail, havent checked into it so could be
        // something else but seems like its this.

        // looks to be that tailCounter is off by 1 when it creates its third tail.

        // may want to call this from createTailDynamically
        for counter from foodEatenTemp to "2" using "-1"
        debug
            move snakeTail(foodEatenTemp) to snakeTail(foodEatenTempMin1)
            //decr tailCounterTemp
            decr foodEatenTemp
            decr foodEatenTempMin1
            //decr tailMinus1
        repeat
        decr tailCounter

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
snakeDiedFromTail lfunction
    entry

    display "How the fuck did this trigger. Snake died from tail??? HOW"
    stop
    //show game over, retry, probably call main again
    //else, end

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
snakeEatsFood lfunction
    entry
    display "Delicious food!"
    //update score
    //extend tail
    incr foodEaten
    call dynamicTailCreation    

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
dynamicTailCreation function

    entry
leftPlus48      integer  4
rightPlus48     integer  4
leftP           integer  4
rightP          integer  4
counter         integer  2
    //hacky at best, fix later
    move tailRec.Tailx1 to leftP, leftPlus48
    move tailRec.Taily1 to rightP, rightPlus48

    add 48 to tailRec.Taily1, leftPlus48
    add 48 to tailRec.Tailx1, rightPlus48
   
   
    //dynamically keep creating new tails        
    incr tailCounter       
    create      gwGamePanel;snakeTail(tailCounter)= tailRec.Tailx1:rightPlus48:tailRec.Taily1:leftPlus48:
                "C:\Users\zkofoed\Pictures\snakeBody.png"
 
    move tailRec.Tailx1 to tailTracker[tailCounter,1]
    move tailRec.Taily1 to tailTracker[tailCounter,2]
    activate snakeTail(tailCounter)

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
handleSnakeDirection function
eatRecent         integer            ^
    entry

    debug
    switch headOfSnake.direction
        case 1     //  1 = up

            move 0 to gameBoardArray[arrayNavigation.row+1,arrayNavigation.column] 
            setprop gwTestSprite, top=headOfSnake.x1   
            
        case 2     //  2 = down

            move 0 to gameBoardArray[arrayNavigation.row-1,arrayNavigation.column]
            setprop gwTestSprite, top=headOfSnake.x1

        case 3     //  3 = left

            move 0 to gameBoardArray[arrayNavigation.row,arrayNavigation.column+1]
            setprop gwTestSprite, left=headOfSnake.y1

        case 4     //  4 = right
            
            move 0 to gameBoardArray[arrayNavigation.row,arrayNavigation.column-1]
            setprop gwTestSprite, left=headOfSnake.y1

        endswitch

    if (tailCounter)
        call deleteTail  
    endif    

    if (foodEaten)
        call dynamicTailCreation
    endif

    functionend
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////