//
//  BlockNode.h
//  Game_Pazzle
//
//  Created by Александр on 09.10.15.
//  Copyright © 2015 Александр. All rights reserved.
//

#ifndef BlockNode_h
#define BlockNode_h


#endif /* BlockNode_h */

#import <SpriteKit/SpriteKit.h>

@interface BlockNode : SKSpriteNode

@property (nonatomic, assign) NSUInteger row; //строка
@property (nonatomic, assign) NSUInteger col; //столбец

- (BlockNode *)initWithRow:(NSUInteger)row
                andCollumn:(NSUInteger)column
                withColor: (UIColor *)color
                   andSize:(CGSize)size
                    andTop:(NSUInteger)toper;

@end