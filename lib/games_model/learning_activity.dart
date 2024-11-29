class LearningActivityItem {
  final List<String> imageUrls;
  final dynamic correctOrder; // This can be either List<String> or List<int>

  LearningActivityItem({required this.imageUrls, required this.correctOrder});
}

// Sample data for three levels
List<List<LearningActivityItem>> learningActivities = [
  // Level 1
  [
    LearningActivityItem(
      imageUrls: [
        'assets/lab1.png',
        'assets/lab2.png',
        'assets/lab3.png',
        'assets/lab4.png'
      ],
      correctOrder: [
        'assets/lab1.png',
        'assets/lab2.png',
        'assets/lab3.png',
        'assets/lab4.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lab11.png',
        'assets/lab22.png',
        'assets/lab33.png',
        'assets/lab44.png'
      ],
      correctOrder: [
        'assets/lab11.png',
        'assets/lab22.png',
        'assets/lab33.png',
        'assets/lab44.png'
      ],
    ),
      LearningActivityItem(
      imageUrls: [
        'assets/lab111.png',
        'assets/lab222.png',
        'assets/lab333.png',
        'assets/lab444.png'
      ],
      correctOrder: [
        'assets/lab111.png',
        'assets/lab222.png',
        'assets/lab333.png',
        'assets/lab444.png'
      ],
    ),
      LearningActivityItem(
      imageUrls: [
        'assets/lab1111.png',
        'assets/lab2222.png',
        'assets/lab3333.png',
        'assets/lab4444.png'
      ],
      correctOrder: [
        'assets/lab1111.png',
        'assets/lab2222.png',
        'assets/lab3333.png',
        'assets/lab4444.png'
      ],
    ),
      LearningActivityItem(
      imageUrls: [
        'assets/lab11111.png',
        'assets/lab22222.png',
        'assets/lab33333.png',
        'assets/lab44444.png'
      ],
      correctOrder: [
        'assets/lab11111.png',
        'assets/lab22222.png',
        'assets/lab33333.png',
        'assets/lab44444.png'
      ],
    ),
      LearningActivityItem(
      imageUrls: [
        'assets/lab111111.png',
        'assets/lab222222.png',
        'assets/lab333333.png',
        'assets/lab444444.png'
      ],
      correctOrder: [
        'assets/lab111111.png',
        'assets/lab222222.png',
        'assets/lab333333.png',
        'assets/lab444444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lab1111111.png',
        'assets/lab2222222.png',
        'assets/lab3333333.png',
        'assets/lab4444444.png'
      ],
      correctOrder: [
        'assets/lab1111111.png',
        'assets/lab2222222.png',
        'assets/lab3333333.png',
        'assets/lab4444444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lab11111111.png',
        'assets/lab22222222.png',
        'assets/lab33333333.png',
        'assets/lab44444444.png'
      ],
      correctOrder: [
        'assets/lab11111111.png',
        'assets/lab22222222.png',
        'assets/lab33333333.png',
        'assets/lab44444444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lab111111111.png',
        'assets/lab222222222.png',
        'assets/lab333333333.png',
        'assets/lab444444444.png'
      ],
      correctOrder: [
        'assets/lab111111111.png',
        'assets/lab222222222.png',
        'assets/lab333333333.png',
        'assets/lab444444444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lab1111111111.png',
        'assets/lab2222222222.png',
        'assets/lab3333333333.png',
        'assets/lab4444444444.png'
      ],
      correctOrder: [
        'assets/lab1111111111.png',
        'assets/lab2222222222.png',
        'assets/lab3333333333.png',
        'assets/lab4444444444.png'
      ],
    ),
    // Add more items as needed for level 1
  ],

  // Level 2
  [
    LearningActivityItem(
      imageUrls: [
        'assets/lam1.png',
        'assets/lam2.png',
        'assets/lam3.png',
        'assets/lam4.png'
      ],
      correctOrder: [
        'assets/lam1.png',
        'assets/lam2.png',
        'assets/lam3.png',
        'assets/lam4.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lam11.png',
        'assets/lam22.png',
        'assets/lam33.png',
        'assets/lam44.png'
      ],
      correctOrder: [
        'assets/lam11.png',
        'assets/lam22.png',
        'assets/lam33.png',
        'assets/lam44.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lam111.png',
        'assets/lam222.png',
        'assets/lam333.png',
        'assets/lam444.png'
      ],
      correctOrder: [
        'assets/lam111.png',
        'assets/lam222.png',
        'assets/lam333.png',
        'assets/lam444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lam1111.png',
        'assets/lam2222.png',
        'assets/lam3333.png',
        'assets/lam4444.png'
      ],
      correctOrder: [
        'assets/lam1111.png',
        'assets/lam2222.png',
        'assets/lam3333.png',
        'assets/lam4444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lam11111.png',
        'assets/lam22222.png',
        'assets/lam33333.png',
        'assets/lam44444.png'
      ],
      correctOrder: [
        'assets/lam11111.png',
        'assets/lam22222.png',
        'assets/lam33333.png',
        'assets/lam44444.png'
      ],
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lam111111.png',
        'assets/lam222222.png',
        'assets/lam333333.png',
        'assets/lam444444.png'
      ],
      correctOrder: [
        'assets/lam111111.png',
        'assets/lam222222.png',
        'assets/lam333333.png',
        'assets/lam444444.png'
      ],
    ),
    // Add more items as needed for level 2
  ],

  // Level 3 with integer-based correctOrder
  [
    LearningActivityItem(
      imageUrls: [
        'assets/lah1.png',
        'assets/lah2.png',
        'assets/lah3.png',
        'assets/lah4.png'
      ],
      correctOrder: [6, 1, 4, 8], // Integer order for level 3
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lah11.png',
        'assets/lah22.png',
        'assets/lah33.png',
        'assets/lah44.png'
      ],
      correctOrder: [2, 8, 0, 9], // Integer order for level 3
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lah111.png',
        'assets/lah222.png',
        'assets/lah333.png',
        'assets/lah444.png'
      ],
      correctOrder: [2, 1, 3, 0], // Integer order for level 3
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lah1111.png',
        'assets/lah2222.png',
        'assets/lah3333.png',
        'assets/lah4444.png'
      ],
      correctOrder: [4, 4, 6, 3], // Integer order for level 3
    ),
    LearningActivityItem(
      imageUrls: [
        'assets/lah11111.png',
        'assets/lah22222.png',
        'assets/lah33333.png',
        'assets/lah44444.png'
      ],
      correctOrder: [3, 6, 4, 5], // Integer order for level 3
    ),
    // Add more items as needed for level 3
  ],
];