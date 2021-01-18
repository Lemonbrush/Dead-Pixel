//
//  BlockNode.m
//  Game_Pazzle
//
//  Created by Александр on 09.10.15.
//  Copyright © 2015 Александр. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockNode.h"

@implementation BlockNode

- (BlockNode *)initWithRow:(NSUInteger)row
                andCollumn:(NSUInteger)column
                 withColor: (UIColor *)color
                   andSize:(CGSize)size
                    andTop:(NSUInteger)toper

{
    self = [super initWithColor:color size:size];
    
    if(self)
    {
        self.row = row;
        self.col = column;
        
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width, size.height)]; //уменьшаем на 2 пикселя для отсутствия просветов между блоками
        self.physicsBody.restitution = 0.f;
        
        CGFloat yPoint = 0.0;
        
        CGFloat xPoint = (size.width / 2) + self.col * size.width; //ширину блока делим на 2 и прибавляем к месту указанному в col
        if(toper == 0){yPoint = 1132 + (size.height / 2) + self.row * size.height;}//аналогично с высотой,  только появляются блоки за пределами экрана
        else yPoint = 1132 * toper + (size.height / 2) + self.row * size.height;
        
        self.zPosition = 2;

        
        self.position = CGPointMake(xPoint, yPoint); //задаем позицию
        self.physicsBody.allowsRotation = NO; //не отлетает в стороны
        
        if([self.color isEqual:[UIColor redColor]]){self.texture = [SKTexture textureWithImageNamed:@"red"];} //красный
        if([self.color isEqual:[UIColor greenColor]]){self.texture = [SKTexture textureWithImageNamed:@"green"];} //зеленый
        if([self.color isEqual:[UIColor blueColor]]){self.texture = [SKTexture textureWithImageNamed:@"blue"];} //голубой
        if([self.color isEqual:[UIColor yellowColor]]){self.texture = [SKTexture textureWithImageNamed:@"yellow"];}//желтый
        

        
        //SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        //self.node.sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    }
    
    return self;
}

@end
