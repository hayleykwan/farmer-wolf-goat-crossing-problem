%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                %
%         276 Introduction to Prolog             %
%                                                %
%         Coursework 2015-16 (crossings)         %
%                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ------------  (utilities) DO NOT EDIT

forall(P,Q) :- \+ (P, \+ Q).


app_select(X,List,Remainder) :-
  append(Front, [X|Back], List),
  append(Front, Back, Remainder).


% The following might be useful for testing.
% You may edit it if you want to adjust
% the layout. DO NOT USE it in your submitted code.

write_list(List) :-
  forall(member(X, List),
         (write('  '), write(X), nl)
        ).


% solutions for testing 

solution([f+g,f,f+w,f+g,f+c,f,f+b,f,f+g]).
solution([f+g,f,f+c,f+g,f+w,f,f+b,f,f+g]).
solution([f+g,f,f+b,f,f+w,f+g,f+c,f,f+g]).
solution([f+g,f,f+b,f,f+c,f+g,f+w,f,f+g]).


%% ------------ END (utilities)

%% ----- STEP 1 -----

safe([f|_]).

safe(Bank) :-
  \+ member(f, Bank),
  \+ (member(w, Bank), member(g, Bank)),
  \+ (member(g, Bank), member(c, Bank)).




%% ----- STEP 2 -----

safe_state(North-South) :-
  safe(North),
  safe(South),
  \+ (member(X, North), member(X, South)).




%% ----- STEP 3 -----

equiv(N1-S1, N2-S2) :-
  forall(member(X, N1), member(X, N2)),
  forall(member(Y, S1), member(Y, S2)),
  forall(member(Y, N2), member(Y, N1)),
  forall(member(Y, S2), member(Y, S1)).




%% ----- STEP 4 -----

goal(State) :-
  State = []-[f|_],
  equiv(State, []-[f,w,g,c,b]).




%% ----- STEP 5 -----

visited([],[]).   

visited(State, [H|_]) :-
  equiv(State, H).

visited(State, [_|T]) :-
  visited(State, T).




%% ----- STEP 6 -----

select(X, List, Remainder) :-
  select_acc(X, List, Remainder, []).


select_acc(X, [X|T], Remainder, Acc) :-
  append(Acc, T, Remainder).

select_acc(X, [H|T], Remainder, Acc) :-
  append(Acc, [H], A),
  select_acc(X, T, Remainder, A).




%% ----- STEP 7 -----

crossing([f|North]-South, f, North-[f|South]).

crossing(North-[f|South], f, [f|North]-South).

crossing([f|N1]-South, f+X, N2-[f,X | South]):-
  member(X, N1),
  select(X, N1, N2).

crossing(North-[f|S1], f+X, [f,X|North]-S2):-
  member(X, S1),
  select(X, S1, S2).



%% ----- STEP 8 -----

journey(State, _, []) :- 
  goal(State).

journey(State, History, [Move|Seq]) :- 
  crossing(State, Move, Next),
  \+ visited(Next, History),
  safe_state(Next),
  journey(Next, [Next|History], Seq).

succeeds(Sequence) :-
  journey([f,w,g,c,b]-[], [], Sequence).




%% ----- STEP 9 -----

count_items([], []).

count_items(List, Stats) :-
  count_items_acc(List, [], Stats).

count_items_acc([], Acc, Acc).

count_items_acc([H|T], Acc, Stats) :-
  \+ member((H, _), Acc),
  append(Acc, [(H, 1)], A),
  count_items_acc(T, A, Stats).

count_items_acc([H|T], Acc, Stats) :-
  append(HeadAcc, [(H, OldCount) | TailAcc] , Acc),
  append(HeadAcc, [(H, N) | TailAcc], A),
  N is OldCount+1,
  count_items_acc(T, A, Stats).




%% ----- STEP 10 -----

g_journeys(Seq, N) :-
  succeeds(Seq),
  count_items(Seq, Stats),
  member((f+g, N), Stats).

