//
//  Title.m
//  Game_Pazzle
//
//  Created by Александр on 09.10.15.
//  Copyright © 2015 Александр. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "Title.h"
#import "GameViewController.h"
#import "GameScene.h"
#import "BlockNode.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface Title()
{
    SKSpriteNode * _background;
    SKSpriteNode * _gameLogo;
    SKSpriteNode * _tittleFon;
    SKSpriteNode * _settingsBoard;
    
    SKSpriteNode * _classicButton;
    SKSpriteNode * _1000PixelsButton;
    SKSpriteNode * _infinityButton;
    SKSpriteNode * _settingsButton;
    
    SKSpriteNode * _soundButton;
    SKSpriteNode * _musicButton;
    SKSpriteNode * _leaderboardsButton;
    SKSpriteNode * _downButton;
    SKSpriteNode * _mailBoard;
    
    AVAudioPlayer * player; //фоновыя музыка
    AVAudioPlayer * bum; //звуки
    
    BOOL _settingsBoardOn;
    BOOL _musicPlayBool;
    BOOL _soundsPlayBool;
    BOOL _mailOn;
}

@end

@implementation Title

-(void)didMoveToView:(SKView *)view {
    
    self.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0]; //цвет фона
    self.scene.size = CGSizeMake(640, 1132);
    
    NSNumber * musicPlay = [[NSUserDefaults standardUserDefaults]objectForKey:@"music"];//достаем очки из памяти приложения
    _musicPlayBool = [musicPlay boolValue]; //конвертируем в integer
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"07 - Doo Wop"
                                                              ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                    error:nil];
    player.numberOfLoops = 999999;
    
    if(_musicPlayBool){[player setVolume:1];}else{[player setVolume:0];}
    
    [player play];
    
    
    
    NSNumber *soundsPlay = [[NSUserDefaults standardUserDefaults]objectForKey:@"sound"];
    _soundsPlayBool = [soundsPlay boolValue];
    
    NSString *clickFilePath = [[NSBundle mainBundle] pathForResource:@"click"ofType:@"wav"];
    NSURL *clickFileURL = [NSURL fileURLWithPath:clickFilePath];
    bum = [[AVAudioPlayer alloc] initWithContentsOfURL:clickFileURL error:nil];
    
    if(_soundsPlayBool){[bum setVolume:1];}else{[bum setVolume:0];}
    
    //--------------------------------------------------------------------------------------------------------
    
    _classicButton = [SKSpriteNode spriteNodeWithImageNamed:@"classic"];
    _classicButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 80);
    _classicButton.zPosition = 4;
    [self addChild:_classicButton];
    
    _1000PixelsButton = [SKSpriteNode spriteNodeWithImageNamed:@"1000Pixels"];
    _1000PixelsButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 210 );
    _1000PixelsButton.zPosition = 3;
    [self addChild:_1000PixelsButton];
    
    _infinityButton = [SKSpriteNode spriteNodeWithImageNamed:@"infinity"];
    _infinityButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 340 );
    _infinityButton.zPosition = 2;
    [self addChild:_infinityButton];
    
    _settingsButton = [SKSpriteNode spriteNodeWithImageNamed:@"settings"];
    _settingsButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 470 );
    _settingsButton.zPosition = 1;
    [self addChild:_settingsButton];
    
    _settingsBoard = [SKSpriteNode spriteNodeWithImageNamed:@"settingsBoard"];
    _settingsBoard.position = CGPointMake(320, -192);
    _settingsBoard.zPosition = 6;
    [self addChild:_settingsBoard];
     
    _tittleFon = [SKSpriteNode spriteNodeWithImageNamed:@"tittleFon"];
    _tittleFon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _tittleFon.zPosition = -1;
    [self addChild:_tittleFon];
    
    _gameLogo = [SKSpriteNode spriteNodeWithImageNamed:@"gameLogo"];
    _gameLogo.position = CGPointMake(640/2, 850);
    _gameLogo.zPosition = 5;
    [self addChild:_gameLogo];
    
    if(_musicPlayBool){_musicButton = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonMusic"];}else{_musicButton = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonMusicEnd"];}
    _musicButton.position = CGPointMake(245, 67 - 192);
    _musicButton.zPosition = 7;
    [self addChild:_musicButton];
    
    if(_soundsPlayBool){_soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonSounds"];}else{_soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonSoundsEnd"];}
    _soundButton.position = CGPointMake(99, 67 - 192);
    _soundButton.zPosition = 7;
    [self addChild:_soundButton];
    
    _leaderboardsButton = [SKSpriteNode spriteNodeWithImageNamed:@"i"];
    _leaderboardsButton.position = CGPointMake(538, 67 - 192);
    _leaderboardsButton.zPosition = 7;
    [self addChild:_leaderboardsButton];
    
    _downButton = [SKSpriteNode spriteNodeWithImageNamed:@"downButton"];
    _downButton.position = CGPointMake(392, 67 - 192);
    _downButton.zPosition = 7;
    [self addChild:_downButton];
    
    _mailBoard = [SKSpriteNode spriteNodeWithImageNamed:@"myMail"];
    _mailBoard.position = CGPointMake(245, 67 -192);
    _mailBoard.size = CGSizeMake(_mailBoard.size.width*1.4, _mailBoard.size.height*1.4);
    _mailBoard.zPosition = 7;
    _mailBoard.hidden = YES;
    [self addChild:_mailBoard];
    
    
    
    [_gameLogo runAction:[SKAction rotateByAngle:0.3 duration:1]];
    
    SKAction * gameLogoPerewP = [SKAction rotateByAngle:-0.6 duration:5];
    SKAction * gameLogoPerewM = [SKAction rotateByAngle:0.6 duration:5];
    SKAction * logoAction = [SKAction sequence:@[gameLogoPerewP,gameLogoPerewM]];
    
    [_gameLogo runAction:[SKAction repeatActionForever: logoAction]];
    
    _settingsBoardOn = NO;
    _mailOn = NO;
    
    //--------------------------------------------------------------------------------------------------------
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { //изменить на нажатие только по лэйблу
    
    UITouch * touch = [touches anyObject]; //объявляем касание
    CGPoint location = [touch locationInNode:self]; //сохраняем коардинаты касания
    SKNode * node = [self nodeAtPoint:location]; //сохраняем в новую переменную SKNode которому пренадлежат коардинаты касания
    
    if([node isEqual:_gameLogo]){
    
        SKAction * logoMen = [SKAction scaleBy:0.90 duration:0.1];
        SKAction * logoBol = [SKAction scaleTo:1 duration:0.1];
        SKAction * logoAct = [SKAction sequence:@[logoMen,logoBol]];

        [_gameLogo runAction:logoAct];
        
        SKSpriteNode * block;
        switch (rand()%5) {
            case 1:{block = [SKSpriteNode spriteNodeWithImageNamed:@"green"];break;}
            case 2:{block = [SKSpriteNode spriteNodeWithImageNamed:@"blue"];break;}
            case 3:{block = [SKSpriteNode spriteNodeWithImageNamed:@"red"];break;}
            case 4:{block = [SKSpriteNode spriteNodeWithImageNamed:@"yellow"];break;}
                
            default:{block = [SKSpriteNode spriteNodeWithImageNamed:@"red"];break;}
        }

        block.position = CGPointMake(_gameLogo.position.x, _gameLogo.position.y - 200);
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(block.size.width, block.size.height)];
        block.zPosition = 0;
        [self addChild:block];
        
        if(rand()%2 == 1){
        [block.physicsBody applyImpulse:CGVectorMake(rand()%100, rand()%100)];
        }else{
           [block.physicsBody applyImpulse:CGVectorMake(-(rand()%100), -(rand()%100))];
            
        }
    }
    
    if([node isEqual:_classicButton]){
        
        [bum play];
        
        SKAction * logoBig = [SKAction scaleTo:1.10 duration:0.1];
        SKAction * logoTiny = [SKAction scaleTo:1 duration:0.1];
        
        SKAction * logoAct = [SKAction sequence:@[logoBig,logoTiny]];
        SKAction * buttonAct = [SKAction sequence:@[[SKAction scaleTo:0.80 duration:0.1],[SKAction moveToY:850 duration:0.2]]];
        
        [_classicButton runAction:buttonAct completion:^(){
        
            [_gameLogo runAction:logoAct completion:^(){
            
                [player setVolume:0];
                
                GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
                SKTransition * transition = [SKTransition fadeWithDuration:1.0];
                scene.scene.size = self.size;
                
                scene.gameLevel = 1;
                
                [self.view presentScene:scene transition:transition];
            
            }];
        
        }];

        }
    
    if ([node isEqual:_1000PixelsButton]){
        
        [bum play];
    
        SKAction * logoBig = [SKAction scaleTo:1.10 duration:0.1];
        SKAction * logoTiny = [SKAction scaleTo:1 duration:0.1];
        
        SKAction * logoAct = [SKAction sequence:@[logoBig,logoTiny]];
        SKAction * buttonAct = [SKAction sequence:@[[SKAction scaleTo:0.80 duration:0.1],[SKAction moveToY:850 duration:0.2]]];
        
        [_1000PixelsButton runAction:buttonAct completion:^(){
            
            [_gameLogo runAction:logoAct completion:^(){
                
                [player setVolume:0];
                
                GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
                SKTransition * transition = [SKTransition fadeWithDuration:1.0];
                scene.scene.size = self.size;
                
                scene.gameLevel = 2;
                
                [self.view presentScene:scene transition:transition];
                
            }];
            
        }];
        
    }
    
    if ([node isEqual:_infinityButton]){
        
        [bum play];
    
        SKAction * logoBig = [SKAction scaleTo:1.10 duration:0.1];
        SKAction * logoTiny = [SKAction scaleTo:1 duration:0.1];
        
        SKAction * logoAct = [SKAction sequence:@[logoBig,logoTiny]];
        SKAction * buttonAct = [SKAction sequence:@[[SKAction scaleTo:0.80 duration:0.1],[SKAction moveToY:850 duration:0.2]]];
        
        [_infinityButton runAction:buttonAct completion:^(){
            
            [_gameLogo runAction:logoAct completion:^(){
                
                [player setVolume:0];
                
                GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
                SKTransition * transition = [SKTransition fadeWithDuration:1.0];
                scene.scene.size = self.size;
                
                scene.gameLevel = 3;
                
                [self.view presentScene:scene transition:transition];
                
            }];
            
        }];
    
    }
    
    if ([node isEqual:_settingsButton]){
        
        [bum play];
    
        if(!_settingsBoardOn){
            
            SKAction * hidden = [SKAction fadeOutWithDuration:0.25];
            SKAction * act =    [SKAction scaleTo:0.90 duration:0.10];
        
            SKAction * move = [SKAction sequence:@[act,hidden]];
        
        
            [_settingsButton runAction:move completion:^{
            
                [_settingsBoard runAction:[SKAction moveToY:75 duration:0.1]];
            
                [_mailBoard runAction:[SKAction moveToY:67 duration:0.1]];
                [_musicButton runAction:[SKAction moveToY:67 duration:0.1]];
                [_soundButton runAction:[SKAction moveToY:67 duration:0.1]];
                [_leaderboardsButton runAction:[SKAction moveToY:67 duration:0.1]];
                [_downButton runAction:[SKAction moveToY:67 duration:0.1]];

                _settingsBoardOn = YES;
        
            }];
            
        }

    
    }
    
    if ([node isEqual:_musicButton]){
        
        [bum play];
    
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [_musicButton runAction:animSet completion:^{
            
            if(_musicPlayBool)
            {
                _musicPlayBool = 0;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:_musicPlayBool]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"music"]; //и заменяем старые данные в памяти приложения
                
                [player setVolume:0];
                
                _musicButton.texture = [SKTexture textureWithImageNamed:@"menuDownButtonMusicEnd"];
                
            }else{
                
                _musicPlayBool = 1;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:_musicPlayBool]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"music"]; //и заменяем старые данные в памяти приложения
                
                [player setVolume:1];
                
                _musicButton.texture = [SKTexture textureWithImageNamed:@"menuDownButtonMusic"];
                
            }
            
        }];
    
    }
    
    if ([node isEqual:_soundButton]){
    
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [_soundButton runAction:animSet completion:^{
            
            if(_soundsPlayBool)
            {
                _soundsPlayBool = 0;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:_soundsPlayBool]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"sound"]; //и заменяем старые данные в памяти приложения
                
                [bum setVolume:0];
                
                _soundButton.texture = [SKTexture textureWithImageNamed:@"menuDownButtonSoundsEnd"];
                
            }else{
                
                _soundsPlayBool = 1;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:_soundsPlayBool]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"sound"]; //и заменяем старые данные в памяти приложения
                
                [bum setVolume:1];
                
                _soundButton.texture = [SKTexture textureWithImageNamed:@"menuDownButtonSounds"];
                
            }
            
        }];
    
    }
    
    if ([node isEqual:_leaderboardsButton]){
        
        [bum play];

        SKAction * buttonAct = [SKAction sequence:@[[SKAction scaleTo:0.90 duration:0.1],[SKAction scaleTo:1 duration:0.1]]];
        
        [_leaderboardsButton runAction:buttonAct completion:^(){
        
            if(!_mailOn)
            {
                [_soundButton runAction:[SKAction fadeOutWithDuration:0.1]];
                [_musicButton runAction:[SKAction fadeOutWithDuration:0.1]];
                [_downButton runAction:[SKAction fadeOutWithDuration:0.1] completion:^(){
                
                    _mailBoard.hidden = NO;
                
                }];
                
                _mailOn = YES;
                
                
                
            }else {
                
                [_soundButton runAction:[SKAction fadeInWithDuration:0.1]];
                [_musicButton runAction:[SKAction fadeInWithDuration:0.1]];
                [_downButton runAction:[SKAction fadeInWithDuration:0.1]];
                
                _mailOn = NO;
                
                _mailBoard.hidden = YES;
            }
        
        }];
        
    }
    
    if ([node isEqual:_downButton]){
        
        [bum play];
    
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        SKAction * hidden = [SKAction fadeInWithDuration:0.25];
        SKAction * act =    [SKAction scaleTo:1 duration:0.10];
        
        SKAction * move = [SKAction sequence:@[act,hidden]];
        
        [_downButton runAction:animSet completion:^(){
            
        
            [_musicButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_soundButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_leaderboardsButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_downButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_mailBoard runAction:[SKAction moveToY:67 - 192 duration:0.1] completion:^(){
            
                [_soundButton runAction:[SKAction fadeInWithDuration:0.1]];
                [_musicButton runAction:[SKAction fadeInWithDuration:0.1]];
                [_downButton runAction:[SKAction fadeInWithDuration:0.1]];
                
                _mailOn = NO;
                
                _mailBoard.hidden = YES;
            
            }];
            
            [_settingsBoard runAction:[SKAction moveToY:-192 duration:0.1] completion:^(){
                
                [_settingsButton runAction:move];
                
                _settingsBoardOn = NO;
             
            }];
        }];
    
    }
    
    if(_settingsBoardOn && (location.y > 150)){
        
        SKAction * hidden = [SKAction fadeInWithDuration:0.25];
        SKAction * act =    [SKAction scaleTo:1 duration:0.10];
        
        SKAction * move = [SKAction sequence:@[act,hidden]];
            
            [_musicButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_soundButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_leaderboardsButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_downButton runAction:[SKAction moveToY:67 - 192 duration:0.1]];
            [_mailBoard runAction:[SKAction moveToY:-192 duration:0.1] completion:^(){
        
                _mailBoard.hidden = YES;
        
            }];
        
            [_settingsBoard runAction:[SKAction moveToY:-192 duration:0.1] completion:^(){
            
                [_settingsButton runAction:move];
                
                _settingsBoardOn = NO;
                
                if(_mailOn){
                    
                    [_soundButton runAction:[SKAction fadeInWithDuration:0.1]];
                    [_musicButton runAction:[SKAction fadeInWithDuration:0.1]];
                    [_downButton runAction:[SKAction fadeInWithDuration:0.1]];
                    
                    _mailOn = NO;
                
                };
            
            }];
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end