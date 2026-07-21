import '../domain/exercise.dart';
import '../domain/local_grader.dart';

/// Sample content for the demo, one exercise per supported type.
///
/// In the real app this arrives from the API, one exercise at a time, with the
/// answer key never leaving the server. Here the two halves are simply kept in
/// separate structures: [demoExercises] is what a widget is allowed to see, and
/// [demoAnswerKeys] is what only the grader touches.
const List<SanitizedExercise> demoExercises = [
  SanitizedExercise(
    id: 'ex_01',
    position: 1,
    type: 'multiple_choice',
    prompt: ExercisePrompt(
      instruction: 'Choose the correct form.',
      sentence: 'She ___ to work by train every morning.',
    ),
    options: [
      ExerciseOption(id: 'opt_a', text: 'go'),
      ExerciseOption(id: 'opt_b', text: 'goes'),
      ExerciseOption(id: 'opt_c', text: 'going'),
      ExerciseOption(id: 'opt_d', text: 'is go'),
    ],
  ),
  SanitizedExercise(
    id: 'ex_02',
    position: 2,
    type: 'fill_in_gap',
    prompt: ExercisePrompt(
      instruction: 'Complete the sentence with the correct preposition.',
      sentence: 'The meeting has been moved ___ Tuesday.',
    ),
    options: [],
    gapLength: 2,
  ),
  SanitizedExercise(
    id: 'ex_03',
    position: 3,
    type: 'word_formation',
    prompt: ExercisePrompt(
      context: 'Use the word in brackets to form a noun.',
      instruction: 'Form the correct word.',
      sentence: 'Her ___ of the topic impressed everyone. (KNOW)',
    ),
    options: [],
    gapLength: 9,
  ),
  SanitizedExercise(
    id: 'ex_04',
    position: 4,
    type: 'sentence_transformation',
    prompt: ExercisePrompt(
      instruction: 'Rewrite the second sentence so it means the same.',
      sentence: 'They started the project two years ago.\n(FOR)\n'
          'They ___ on the project for two years.',
    ),
    options: [],
    gapLength: 14,
  ),
  SanitizedExercise(
    id: 'ex_05',
    position: 5,
    type: 'sentence_ordering',
    // No sentence: the shuffled word bank is the entire prompt.
    prompt: ExercisePrompt(
      instruction: 'Put the words in the correct order.',
      sentence: '',
    ),
    options: [
      ExerciseOption(id: 'w_1', text: 'never'),
      ExerciseOption(id: 'w_2', text: 'I'),
      ExerciseOption(id: 'w_3', text: 'been'),
      ExerciseOption(id: 'w_4', text: 'have'),
      ExerciseOption(id: 'w_5', text: 'to'),
      ExerciseOption(id: 'w_6', text: 'Japan'),
    ],
  ),
  SanitizedExercise(
    id: 'ex_06',
    position: 6,
    type: 'sentence_correction',
    prompt: ExercisePrompt(
      instruction: 'Find the mistake and rewrite the sentence.',
      sentence: 'He dont like waiting in long queues.',
    ),
    options: [],
  ),
];

/// Answer keys, held apart from the exercises above.
final Map<String, AnswerKey> demoAnswerKeys = {
  'ex_01': const AnswerKey(
    exerciseId: 'ex_01',
    answer: 'opt_b',
    explanation: ExerciseExplanation(
      rule: 'Present simple, third person singular takes an -s ending.',
      examples: [
        ExerciseExample(en: 'He works late.', translation: 'On pracuje do pozna.'),
        ExerciseExample(en: 'She goes home.', translation: 'Ona idzie do domu.'),
      ],
    ),
  ),
  'ex_02': const AnswerKey(
    exerciseId: 'ex_02',
    answer: 'to',
    alternatives: ['until', 'till'],
    explanation: ExerciseExplanation(
      rule: 'Move something to a new point in time takes "to".',
      examples: [
        ExerciseExample(
          en: 'The call was moved to Friday.',
          translation: 'Rozmowa zostala przeniesiona na piatek.',
        ),
      ],
    ),
  ),
  'ex_03': const AnswerKey(
    exerciseId: 'ex_03',
    answer: 'knowledge',
    explanation: ExerciseExplanation(
      rule: 'The noun formed from "know" is "knowledge", an irregular form '
          'rather than the expected -ing or -ment ending.',
      examples: [
        ExerciseExample(
          en: 'His knowledge of history is impressive.',
          translation: 'Jego wiedza historyczna robi wrazenie.',
        ),
      ],
    ),
  ),
  'ex_04': const AnswerKey(
    exerciseId: 'ex_04',
    answer: 'have been working',
    alternatives: ['have worked'],
    explanation: ExerciseExplanation(
      rule: 'An action that began in the past and still continues uses the '
          'present perfect with "for" plus a period of time.',
      examples: [
        ExerciseExample(
          en: 'I have been living here for five years.',
          translation: 'Mieszkam tu od pieciu lat.',
        ),
      ],
    ),
  ),
  'ex_05': const AnswerKey(
    exerciseId: 'ex_05',
    answer: 'I have never been to Japan',
    explanation: ExerciseExplanation(
      rule: 'In the present perfect, "never" sits between the auxiliary "have" '
          'and the past participle.',
      examples: [
        ExerciseExample(
          en: 'She has never seen snow.',
          translation: 'Ona nigdy nie widziala sniegu.',
        ),
      ],
    ),
  ),
  'ex_06': const AnswerKey(
    exerciseId: 'ex_06',
    answer: "He doesn't like waiting in long queues",
    alternatives: [
      'He does not like waiting in long queues',
      'He doesnt like waiting in long queues',
    ],
    explanation: ExerciseExplanation(
      rule: 'Third person singular negatives use "does not" or "doesn\'t", '
          'and the main verb stays in its base form.',
      examples: [
        ExerciseExample(
          en: "She doesn't work on Sundays.",
          translation: 'Ona nie pracuje w niedziele.',
        ),
      ],
    ),
  ),
};
