movie("Titanic", [basedOnTrueStory, inEnglish]).
movie("Inception", [after2000, inEnglish]).
movie("The Matrix", [after2000]).

question(basedOnTrueStory, "Фильм основан на реальных событиях?").
question(after2000, "Фильм снят после 2000?").
question(inEnglish, "Фильм снят на английском?").

check_in_features(Feature, Movie) :-
    movie(Movie,L), member(Feature, L),!.

filter_by_feature(Movies, Feature, FilteredMovies) :-
    include(check_in_features(Feature), Movies, FilteredMovies).

filter_by_feature_not(Movies, Feature, Result) :-
    include(check_in_features(Feature), Movies, FilteredMovies),
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
    ->  filter_by_feature(Movies, Question, FilteredMovies), determine_question(FilteredMovies, NewQuestion), ask_question(NewQuestion, FilteredMovies),!
    ;   filter_by_feature_not(Movies, Question, FilteredMovies), determine_question(FilteredMovies, NewQuestion), ask_question(NewQuestion, FilteredMovies),!
    ),!.

all_movie_titles(Titles) :-
    findall(Title, movie(Title, _), Titles).