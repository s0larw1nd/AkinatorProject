:- set_prolog_flag(encoding, utf8).

movie("Titanic", [basedOnTrueStory, inEnglish]).
movie("Inception", [after2000, inEnglish]).
movie("The Matrix", [after2000]).

question(basedOnTrueStory, "Is film based on real events?").
question(after2000, "Was film created after 2000?").
question(inEnglish, "Was film created in english?").

check_in_features(Feature, Movie) :-
    movie(Movie,L), member(Feature, L),!.

check_all_features([], _).
check_all_features([Feature|Rest], Movie) :-
    check_in_features(Feature, Movie),
    check_all_features(Rest, Movie).

%filter_by_feature(Movies, Feature, FilteredMovies) :-
    %include(check_in_features(Feature), Movies, FilteredMovies).
filter_by_feature(Movies, Features, FilteredMovies) :-
    include(check_all_features(Features), Movies, FilteredMovies).

filter_by_feature_not(Movies, [], Movies).
filter_by_feature_not(Movies, Feature, Result) :-
    include(check_all_features(Feature), Movies, FilteredMovies),
    subtract(Movies, FilteredMovies, Result).

collect_tags([], []).
collect_tags([Title|T], AllTags) :-
    movie(Title, Tags),
    collect_tags(T, OtherTags),
    append(Tags, OtherTags, AllTags).

ocurrenceof([] , _, 0).
ocurrenceof([H|T] , H, NewCount):-
    ocurrenceof(T,H,OldCount),
    NewCount is OldCount +1.
ocurrenceof([H|T] , H2, Count):-
    dif(H,H2),
    ocurrenceof(T,H2,Count).

count_ocurrences(_, _, [], []) :- !.
count_ocurrences(Tags, N, [H | Tail], [ H-abs(N - Count) | Tail2]) :-
    ocurrenceof(Tags, H, Count),
    count_ocurrences(Tags, N, Tail, Tail2).

determine_question(Movies, Question) :-
    collect_tags(Movies, Tags),
    list_to_set(Tags, UniqueTags),
    length(Movies, NMovies),
    count_ocurrences(Tags, NMovies, UniqueTags, Occurences),!,
    sort(2, @<, Occurences, Sorted),
    nth0(0,Sorted, QuestionPair),
 	Question-_=QuestionPair.

determine_question_all(Questions_yes, Questions_no, Question) :-
    all_movie_titles(Movies),
    filter_by_feature(Movies, Questions_yes, FilteredYesMovies),
    filter_by_feature_not(FilteredYesMovies, Questions_no, FilteredMovies),
    determine_question(FilteredMovies, Question),!.

ask_first_question :-
    all_movie_titles(Movies),
    determine_question(Movies, Question),
    ask_question(Question, Movies),!.
    
ask_question(_, [H]) :-
    write(H),!.

ask_question(Question, Movies) :-    
    question(Question, Text),
    write(Text), nl,
    write("1. Yes"), nl,
    write("0. No"),
    read(Answer),
    (
    	Answer = 1
    ->  filter_by_feature(Movies, [Question], FilteredMovies), determine_question(FilteredMovies, NewQuestion), ask_question(NewQuestion, FilteredMovies),!
    ;   filter_by_feature_not(Movies, [Question], FilteredMovies), determine_question(FilteredMovies, NewQuestion), ask_question(NewQuestion, FilteredMovies),!
    ),!.

all_movie_titles(Titles) :-
    findall(Title, movie(Title, _), Titles).

main :-
    current_prolog_flag(argv, [List1Str, List2Str]),
    read_from_chars(List1Str, List1),
    read_from_chars(List2Str, List2),
    determine_question_all(List1, List2, Question),
    question(Question,QuestionLine),
    write(Question),nl,
    write(QuestionLine),
    halt.

:- initialization(main, main).