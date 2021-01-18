//
//  GameScene.m
//  Dead Pixel
//
//  Created by Александр on 08.11.15.
//  Copyright (c) 2015 Александр. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GameViewController.h"
#import "GameScene.h"
#import "BlockNode.h"
#import "Title.h"

#define xRow 8
#define yRow 12
#define MIN_BLOCK 2

//объявляем тип данных  GameState
typedef enum{
    STOPPED,
    STARTING,
    PLAYING,
} GameState;
//с 3 состояниями игры: остановлена, в действии и начинает действие

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

@interface GameScene(){
    
    NSArray * _colors; //массив для допустимых цветов блоков в игре
    
    SKSpriteNode * background;
    
    NSUInteger score;//очки
    NSUInteger time;
    NSUInteger timeLeftRounded;
    CFTimeInterval startedTime;//время
    
    GameState gameState;//состояние игры
    
    SKSpriteNode * buttonPause;
    
    NSUInteger blockTop;
    
    SKSpriteNode * endMenu;
    SKSpriteNode * endMenuButtonToMenu;
    SKSpriteNode * endMenuButtonToRestart;
    SKSpriteNode * endMenuButtonToSound;
    SKSpriteNode * endMenuButtonToMusic;
    SKSpriteNode * scoreBoard;
    SKSpriteNode * timeBoard;
    
    SKSpriteNode * num_1; //очки
    SKSpriteNode * num_2;
    SKSpriteNode * num_3;
    
    SKSpriteNode * tNum_1; //время
    SKSpriteNode * tNum_2;
    SKSpriteNode * tNum_3;
    
    BOOL menuOn;
    
    AVAudioPlayer * player; //фоновыя музыка
    AVAudioPlayer * bum;
    
    SKTextureAtlas * numbersList;
    
    NSUInteger timeInPause;
    NSUInteger startPause;
}
@end

// gameLevel
// 1 - обычная
// 2 - время+
// 3 - бесконечная

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    time = 20; //время сессии
    
    if(self.gameLevel == 2)score = 1000;
    
    numbersList = [SKTextureAtlas atlasNamed:@"numbers"];
    
    NSNumber * musicPlay = [[NSUserDefaults standardUserDefaults]objectForKey:@"music"];//достаем очки из памяти приложения
    BOOL musicPlayBool = [musicPlay boolValue]; //конвертируем в integer
    
    NSNumber * soundPlay = [[NSUserDefaults standardUserDefaults]objectForKey:@"sound"];//достаем очки из памяти приложения
    BOOL soundPlayBool = [soundPlay boolValue]; //конвертируем в integer
    
    self.effectMusic = soundPlayBool;
    self.fonMusic = musicPlayBool;
    
    //------
    
    NSString *soundFilePath;
    
    switch (rand()%7) {
        case 1: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"01 - Star Ocean"ofType:@"mp3"];break;}
        case 2: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"03 - Fast-Fast"ofType:@"mp3"];break;}
        case 3: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"05 - The Cool Dance"ofType:@"mp3"];break;}
        case 4: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"08 - Pop Music Will Never Die"ofType:@"mp3"];break;}
        case 5: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"09 - Ты Не Пройдёшь Шреддера (Bonus Track)"ofType:@"mp3"];break;}
        case 6: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"04 - Звездное Небо Новосибирска"ofType:@"mp3"];break;}
            
        default: {soundFilePath = [[NSBundle mainBundle] pathForResource:@"04 - Звездное Небо Новосибирска"ofType:@"mp3"];break;}
    }
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = 999999;
    
    if(self.fonMusic){[player setVolume:1];}else{[player setVolume:0];}
    
    [player play];
    //------
    
    self.scene.size = CGSizeMake(640, 1132);//размер сцены
    self.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];//задаем цвет фона
    self.physicsWorld.gravity = CGVectorMake(0, -100); //задаем гравитацию
    
    menuOn = 0;
    
    _colors = @[[UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor greenColor]]; //задаем количество видов блоков в игре
    
    //--------------------------------------------------------------------------------------------------------
    
    num_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    num_1.position = CGPointMake(57, 54);
    num_1.zPosition = 6;
    [self addChild:num_1];
    
    num_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    num_2.position = CGPointMake(130 , 54);
    num_2.zPosition = 6;
    [self addChild:num_2];
    
    num_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    num_3.position = CGPointMake(203 , 54);
    num_3.zPosition = 6;
    [self addChild:num_3];
    
    
    tNum_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    tNum_1.position = CGPointMake(437, 54);
    tNum_1.zPosition = 6;
    [self addChild:tNum_1];
    
    tNum_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    tNum_2.position = CGPointMake(510, 54);
    tNum_2.zPosition = 6;
    [self addChild:tNum_2];
    
    tNum_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
    tNum_3.position = CGPointMake(583, 54);
    tNum_3.zPosition = 6;
    [self addChild:tNum_3];
    
    scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"scoreBoard"];
    scoreBoard.position = CGPointMake(130, 54);
    scoreBoard.size = CGSizeMake(236, 97);
    scoreBoard.zPosition = 7;
    [self addChild:scoreBoard];
    
    timeBoard = [SKSpriteNode spriteNodeWithImageNamed:@"timeBoard"];
    timeBoard.position = CGPointMake(509, 54);
    timeBoard.size = CGSizeMake(236, 97);
    timeBoard.zPosition = 7;
    [self addChild:timeBoard];
    
    endMenu = [SKSpriteNode spriteNodeWithImageNamed:@"menuPause"];
    endMenu.size = CGSizeMake(640, 150);
    endMenu.position = CGPointMake(320, 0); //320,600
    endMenu.zPosition = 3; //баннер ендменю
    [self addChild:endMenu]; //640 150
    
    endMenuButtonToRestart = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButton"];
    endMenuButtonToRestart.size = CGSizeMake(125, 125);
    endMenuButtonToRestart.zPosition = 4;
    endMenuButtonToRestart.position = CGPointMake(240, 7);
    [self addChild:endMenuButtonToRestart];
    
    if(self.effectMusic){endMenuButtonToSound = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonSounds"];}else{endMenuButtonToSound = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonSoundsEnd"];}
    endMenuButtonToSound.size = CGSizeMake(125, 125);
    endMenuButtonToSound.zPosition = 4;
    endMenuButtonToSound.position = CGPointMake(401, 7);
    [self addChild:endMenuButtonToSound];
    
    if(self.fonMusic){endMenuButtonToMusic = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonMusic"];}else{endMenuButtonToMusic = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonMusicEnd"];}
    endMenuButtonToMusic.size = CGSizeMake(125, 125);
    endMenuButtonToMusic.zPosition = 4;
    endMenuButtonToMusic.position = CGPointMake(557, 7);
    [self addChild:endMenuButtonToMusic];
    
    endMenuButtonToMenu = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonToMenu"];
    endMenuButtonToMenu.size = CGSizeMake(125, 125);
    endMenuButtonToMenu.zPosition = 4;
    endMenuButtonToMenu.position = CGPointMake(84 ,7);
    [self addChild:endMenuButtonToMenu];
    
    
    switch (rand()%5) {
        case 1: {background = [SKSpriteNode spriteNodeWithImageNamed:@"redFon"];;break;}
        case 2: {background = [SKSpriteNode spriteNodeWithImageNamed:@"blueFon"];;break;}
        case 3: {background = [SKSpriteNode spriteNodeWithImageNamed:@"yellowFon"];;break;}
        case 4: {background = [SKSpriteNode spriteNodeWithImageNamed:@"greenFon"];;break;}
            
        default: {background = [SKSpriteNode spriteNodeWithImageNamed:@"yellowFon"];;break;}
    }
    
    background.position = CGPointMake(640/2,1132/2);
    background.zPosition = 1; //фон
    [self addChild:background];
    
    //объявляем блок, который будет являться полом
    SKSpriteNode * band = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(640, 120)];
    band.texture = [SKTexture textureWithImageNamed:@"board"];
    band.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:band.size];
    band.physicsBody.dynamic = NO;
    band.position = CGPointMake(320,60);
    band.zPosition = 5; //нижнее меню
    [self addChild:band]; //выводим на экран
    
    buttonPause = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(120, 120)];
    buttonPause.texture = [SKTexture textureWithImageNamed:@"pause"];
    buttonPause.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:band.size];
    buttonPause.physicsBody.dynamic = NO;
    buttonPause.position = CGPointMake(320,60);
    buttonPause.zPosition = 6; //кнопка паузы
    [self addChild:buttonPause];
    
    //-----------------------------------------------------------
    
    //заполняем поле блоками
    
    for(int j = 0; j<yRow; j++) //указываем количество столбцов
    {
        for(int i = 0; i<xRow; i++) //количество строк
        {
            CGFloat port = 640/xRow; //делим ширину экрана на количество блоков в 1 линии (чтобы блоки заполняли весь экран) и сохраняем
            
            NSUInteger indecs = arc4random() % _colors.count; //выбираем рандомный цветт для блока
            
            BlockNode * node = [[BlockNode alloc] initWithRow:j andCollumn:i withColor:[_colors objectAtIndex:indecs] andSize:CGSizeMake(port, port) andTop:0]; //задаем параметры и создаем блок
            
            [self.scene addChild:node]; //выводим блок на сцену
            
        }
    }
    
    //-------------------------------------------------------------
    
}

/*
 -(void)printSit{
 NSUInteger sit[yRow][xRow];
 NSUInteger positX[yRow][xRow];
 NSUInteger positY[yRow][xRow];
 
 for(BlockNode * node in [self getAllBlocks])
 {
 
 //if([node.color isEqual:[UIColor redColor]]){sit[node.row][node.col] = 1; node.texture = [SKTexture textureWithImageNamed:@"red"];} //красный
 //if([node.color isEqual:[UIColor greenColor]]){sit[node.row][node.col] = 2; node.texture = [SKTexture textureWithImageNamed:@"green"];} //зеленый
 //if([node.color isEqual:[UIColor blueColor]]){sit[node.row][node.col] = 3; node.texture = [SKTexture textureWithImageNamed:@"blue"];} //голубой
 //if([node.color isEqual:[UIColor yellowColor]]){sit[node.row][node.col] = 4; node.texture = [SKTexture textureWithImageNamed:@"yellow"];}//желтый
 
 
 if([node.color isEqual:[UIColor redColor]]){sit[node.row][node.col] = 1; node.color = [UIColor redColor];} //красный
 if([node.color isEqual:[UIColor greenColor]]){sit[node.row][node.col] = 2; node.color = [UIColor greenColor];} //зеленый
 if([node.color isEqual:[UIColor blueColor]]){sit[node.row][node.col] = 3; node.color = [UIColor blueColor];} //голубой
 if([node.color isEqual:[UIColor yellowColor]]){sit[node.row][node.col] = 4; node.color = [UIColor yellowColor];}//желтый
 
 positX[node.row][node.col] = node.col;
 positY[node.row][node.col] = node.row;
 
 
 }
 BlockNode * node;
 
 for(int i = 0; i<yRow;i++)
 {
 for(int j = 0; j<xRow;j++)
 {
 printf("(%lu,%lu)",(unsigned long)positX[i][j],(unsigned long)positY[i][j]);
 
 SKSpriteNode * point = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(5, 5)];
 point.position = CGPointMake((node.size.width / 2) + positX[i][j] * node.size.width,(node.size.height / 2) + positY[i][j] * node.size.height);
 
 point.zPosition = 10;
 
 [self addChild:point];
 }
 printf("\n");
 }
 
 
 for(int i = 0; i<yRow;i++)
 {
 for(int j = 0; j<xRow;j++)
 {
 if(sit[i][j] == 1){printf(" красный  ");}
 if(sit[i][j] == 2){printf(" зеленый ");}
 if(sit[i][j] == 3){printf(" голубой ");}
 if(sit[i][j] == 4){printf(" желтый ");}
 
 }
 printf("\n");
 }
 
 NSLog(@"end");
 NSLog(@" ");
 }
 */

//printSit

- (NSArray *)getAllBlocks{
    NSMutableArray * blocks = [NSMutableArray array]; //объявляем массив для хранения всех данных о всех блоках
    
    for(SKNode * childNode in self.scene.children) //проходимся по всем SKNode в нашей сцене
    {
        if([childNode isKindOfClass:[BlockNode class]]) //и если находим в SKNode родственность с BlockNode классом
        {
            [blocks addObject:childNode]; //добавляем его в массив
        }
    }
    
    return [NSArray arrayWithArray:blocks]; //возвращаем массив с данными о всех блоках на сцене
}

- (BOOL)inRange:(BlockNode *)testNode of:(BlockNode *)baseNode{
    BOOL isRow = (baseNode.row == testNode.row); //переменная показывающая стоят ли блоки в одной строке
    BOOL isCol = (baseNode.col == testNode.col); //переменная показывающая стоят ли блоки в одном столбце
    
    
    CGPointMake(baseNode.position.x + baseNode.size.width/2 + 5, baseNode.position.y + baseNode.size.height/2 + 5);
    
    BOOL oneOffCol = (baseNode.col + 1 == testNode.col || baseNode.col - 1 == testNode.col); //проверка - по бокам сверху/снизу блока это то, что нам нужно? (если индекс столбца блока сверху нажатого блока = индексу столбца нажатого блока или так же снизу)
    BOOL oneOffRow = (baseNode.row + 1 == testNode.row || baseNode.row - 1 == testNode.row); //проверка - по бокам слева/справа блока это то, что нам нужно? так же со строкой
    
    BOOL someColor = [baseNode.color isEqual:testNode.color]; //переменная показывающая одинаковые ли цвета у блоков
    
    //возвращаем результат (разрешение на зачет рядом стоящего блока как "своего") по правилам игры
    return ( (isRow && oneOffCol) || (isCol && oneOffRow) ) && someColor; //возвращает 1 если блоки стоят в одно строке и они прикасаются друг к другу или они стоят в одном столбце и прикасаются друг к другу и у них одинаковый цвет
}

- (NSMutableArray *)nodesToRemove:(NSMutableArray *)removedNodes aroundNodes:(BlockNode *)baseNode{
    
    [removedNodes addObject:baseNode]; //добавляем в массив удаления блоков выбранный блок
    
    for(BlockNode * childNode in [self getAllBlocks]) //проходимся по всем блокам в сцене
    {
        if([self inRange:childNode of:baseNode]) //если блок касается выбранного блока
        {
            if(![removedNodes containsObject:childNode])//если этот блок не содержится в массиве удаленных блоков
            {
                removedNodes = [self nodesToRemove:removedNodes aroundNodes:childNode];
                //добавляем в массив удаленных блоков результат этого метода вызванного уже по отношению к стоящему рядом блоку (в соответствии с правилами)
            }
        }
    }
    
    return removedNodes;//возвращаем массив удаленных блоков
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject]; //объявляем касание
    CGPoint location = [touch locationInNode:self]; //сохраняем коардинаты касания
    SKNode * node = [self nodeAtPoint:location]; //сохраняем в новую переменную SKNode которому пренадлежат коардинаты касания
    
    if([node isEqual:endMenuButtonToRestart]){
        
        if(self.effectMusic)
        {
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [bum play]; //звук
        }
        
        [player setVolume:0];
        
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [endMenuButtonToRestart runAction:animSet completion:^{
            
            GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
            SKTransition * transition = [SKTransition fadeWithDuration:1.0];
            scene.scene.size = self.size;
            
            scene.gameLevel = self.gameLevel;
            
            [self.view presentScene:scene transition:transition];
            
        }];
    }
    
    if([node isEqual:endMenuButtonToMenu]){
        
        if(self.effectMusic)
        {
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [bum play]; //звук
        }
        
        [player setVolume:0];
        
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [endMenuButtonToMenu runAction:animSet completion:^{
            
            Title *scene = [Title unarchiveFromFile:@"GameScene"];
            SKTransition * transition = [SKTransition fadeWithDuration:1.0];
            scene.scene.size = self.size;
            [self.view presentScene:scene transition:transition];
            
        }];
        
    }
    
    if([node isEqual:endMenuButtonToSound]){
        
        if(self.effectMusic)
        {
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [bum play]; //звук
        }
        
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [endMenuButtonToSound runAction:animSet completion:^{
            
            if(self.effectMusic)
            {
                self.effectMusic = 0;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:self.effectMusic]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"sound"]; //и заменяем старые данные в памяти приложения
                
                [bum setVolume:0];
                
                endMenuButtonToSound.texture = [SKTexture textureWithImageNamed:@"menuDownButtonSoundsEnd"];
                
            }else{
                
                self.effectMusic = 1;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:self.effectMusic]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"sound"]; //и заменяем старые данные в памяти приложения
                
                [bum setVolume:1];
                
                endMenuButtonToSound.texture = [SKTexture textureWithImageNamed:@"menuDownButtonSounds"];
                
            }
            
        }];
    }
    
    if([node isEqual:endMenuButtonToMusic]){
        
        if(self.effectMusic)
        {
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [bum play]; //звук
        }
        
        SKAction * buttonActionP = [SKAction scaleTo:0.90 duration:0.1];
        SKAction * buttonActionM = [SKAction scaleTo:1 duration:0.1];
        SKAction * animSet = [SKAction sequence:@[buttonActionP,buttonActionM]];
        
        [endMenuButtonToMusic runAction:animSet completion:^{
            
            if(self.fonMusic)
            {
                self.fonMusic = 0;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:self.fonMusic]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"music"]; //и заменяем старые данные в памяти приложения
                
                [player setVolume:0];
                
                endMenuButtonToMusic.texture = [SKTexture textureWithImageNamed:@"menuDownButtonMusicEnd"];
                
            }else{
                
                self.fonMusic = 1;
                
                NSNumber * musicPlayP = [NSNumber numberWithInteger:self.fonMusic]; //мы их конвертируем в объект
                
                [[NSUserDefaults standardUserDefaults]setObject:musicPlayP forKey:@"music"]; //и заменяем старые данные в памяти приложения
                
                [player setVolume:1];
                
                endMenuButtonToMusic.texture = [SKTexture textureWithImageNamed:@"menuDownButtonMusic"];
                
            }
            
        }];
    }
    
    if([node isEqual:buttonPause]){
        
        if(self.effectMusic)
        {
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [bum play]; //звук
        }
        
        SKAction * act =    [SKAction scaleTo:0.90 duration:0.10];
        SKAction * act2 =   [SKAction scaleTo:1 duration:0.10];
        SKAction * acts =   [SKAction sequence:@[act,act2]];
        
        //[buttonPause runAction:[SKAction repeatActionForever:acts]];
        
        [buttonPause runAction:acts completion:^{
            
            //SKAction * milZum =         [SKAction scaleTo:0.80 duration:0.1];
            //SKAction * maxZum =         [SKAction scaleTo:1    duration:0.1];
            SKAction * menuAction =     [SKAction moveToY:195 duration:0.1];
            SKAction * buttonsAction =  [SKAction moveToY:189 duration:0.1];
            SKAction * menuActionDown = [SKAction moveToY:0 duration:0.1];
            
            if(!menuOn)
            {
                
                buttonPause.texture = [SKTexture textureWithImageNamed:@"playButton"];
                
                SKAction *animSet = [SKAction sequence:@[menuAction]];
                menuOn = 1;
                [endMenuButtonToMenu runAction:buttonsAction];
                [endMenuButtonToRestart runAction:buttonsAction];
                [endMenuButtonToSound runAction:buttonsAction];
                [endMenuButtonToMusic runAction:buttonsAction];
                [endMenu runAction:animSet];
                
            }else{
                
                buttonPause.texture = [SKTexture textureWithImageNamed:@"pause"];
                
                SKAction *animSet = [SKAction sequence:@[menuActionDown]];
                menuOn = 0;
                [endMenuButtonToMenu runAction:animSet];
                [endMenuButtonToRestart runAction:animSet];
                [endMenuButtonToSound runAction:animSet];
                [endMenuButtonToMusic runAction:animSet];
                [endMenu runAction:animSet];
                
                startedTime  += timeInPause;
                
            }
            
        }];
    }
    
    if([node isKindOfClass:[BlockNode class]]){ //если node на который было произведено касание принадлежит BlockNode классу (если это игровой блок)
        
        if(menuOn){
            
            SKAction * menuActionDown = [SKAction moveToY:0 duration:0.1];
            SKAction *animSet = [SKAction sequence:@[menuActionDown]];
            menuOn = 0;
            [endMenuButtonToMenu runAction:animSet];
            [endMenuButtonToRestart runAction:animSet];
            [endMenuButtonToSound runAction:animSet];
            [endMenuButtonToMusic runAction:animSet];
            [endMenu runAction:animSet];
            
            startedTime  += timeInPause;
            
        }
        
        BlockNode * clickedBlock = (BlockNode *)node; //сохраняем блок в новую переменную (даже если объект как-то прошел через условие делаем приведение типа)
        
        //NSLog(@" x = %lu , y = %lu ",(unsigned long)clickedBlock.row,(unsigned long)clickedBlock.col);
        
        NSMutableArray * objectsToRemove = [self nodesToRemove:[NSMutableArray array] aroundNodes:clickedBlock];// //сохраняем в массив...
        
        [self nodeFode:[self topNodes] andIt:0];
        
        if((objectsToRemove.count >= MIN_BLOCK) && (blockTop == 1)) //если количество удаленных блоков больше или равно допустимому количеству
        {
            
            //-----------------------------------------------------------------------
            
            if(self.effectMusic)
            {
                NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Bat" ofType:@"wav"];
                NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
                bum = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
                [bum play]; //звук
            }
            
            //-----------------------------------------------------------------------
            
            if(gameState == STOPPED) //если игра в состоянии STOPPED
            {
                gameState = STARTING; //она переходит в состояние STARTING (чтобы считать начальные данные и перейти в состояние PLAYING)
            }
            
            for(BlockNode * deleteNode in objectsToRemove) //проходимся по блокам в массиве удаленных блоков
            {
                [deleteNode removeFromParent]; //удаляем со сцены блок
                
                for(BlockNode *testNode in [self getAllBlocks]) //проходимся по блокам во всей сцене
                {
                    if(deleteNode.col == testNode.col && (deleteNode.row < testNode.row)) //проверяем стоит ли удаленный блок ниже тестового (упадет ли блок)
                    {
                        --testNode.row; //уменьшаем индекс выше стоящего блока (он падает и меняет индекс)
                        
                    }
                }
                
                if(self.gameLevel != 3)
                {
                    if(self.gameLevel == 1){score++;} //прибавляем 1 очко за 1 удаление
                    if(self.gameLevel == 2 && score != 0){score--;}
                    
                    NSUInteger scorePer = score;
                    
                    int a = (int)scorePer;
                    int n1, n2, n3;
                    
                    n1 = a / 100;
                    n2 = (a - n1 * 100) / 10;
                    n3 = (a - n1 * 100 - n2 * 10);
                    
                    SKTexture * num0 = [numbersList textureNamed:@"0"];
                    SKTexture * num1 = [numbersList textureNamed:@"1"];
                    SKTexture * num2 = [numbersList textureNamed:@"2"];
                    SKTexture * num3 = [numbersList textureNamed:@"3"];
                    SKTexture * num4 = [numbersList textureNamed:@"4"];
                    SKTexture * num5 = [numbersList textureNamed:@"5"];
                    SKTexture * num6 = [numbersList textureNamed:@"6"];
                    SKTexture * num7 = [numbersList textureNamed:@"7"];
                    SKTexture * num8 = [numbersList textureNamed:@"8"];
                    SKTexture * num9 = [numbersList textureNamed:@"9"];
                    
                    if(n1 == 0 && a > 999){[num_1 setTexture:num0];}else{[num_1 setTexture:nil];}
                    if(n1 == 1){[num_1 setTexture:num1];}
                    if(n1 == 2){[num_1 setTexture:num2];}
                    if(n1 == 3){[num_1 setTexture:num3];}
                    if(n1 == 4){[num_1 setTexture:num4];}
                    if(n1 == 5){[num_1 setTexture:num5];}
                    if(n1 == 6){[num_1 setTexture:num6];}
                    if(n1 == 7){[num_1 setTexture:num7];}
                    if(n1 == 8){[num_1 setTexture:num8];}
                    if(n1 == 9){[num_1 setTexture:num9];}
                    
                    if(n2 == 0 && a > 99){[num_2 setTexture:num0];}else{[num_2 setTexture:nil];}
                    if(n2 == 1){[num_2 setTexture:num1];}
                    if(n2 == 2){[num_2 setTexture:num2];}
                    if(n2 == 3){[num_2 setTexture:num3];}
                    if(n2 == 4){[num_2 setTexture:num4];}
                    if(n2 == 5){[num_2 setTexture:num5];}
                    if(n2 == 6){[num_2 setTexture:num6];}
                    if(n2 == 7){[num_2 setTexture:num7];}
                    if(n2 == 8){[num_2 setTexture:num8];}
                    if(n2 == 9){[num_2 setTexture:num9];}
                    
                    if(n3 == 0){[num_3 setTexture:num0];}
                    if(n3 == 1){[num_3 setTexture:num1];}
                    if(n3 == 2){[num_3 setTexture:num2];}
                    if(n3 == 3){[num_3 setTexture:num3];}
                    if(n3 == 4){[num_3 setTexture:num4];}
                    if(n3 == 5){[num_3 setTexture:num5];}
                    if(n3 == 6){[num_3 setTexture:num6];}
                    if(n3 == 7){[num_3 setTexture:num7];}
                    if(n3 == 8){[num_3 setTexture:num8];}
                    if(n3 == 9){[num_3 setTexture:num9];}
                    
                }
            }
            
            //отрисовываем недостающие блоки --------------------------------------------------------------
            
            NSUInteger totalRows[xRow]; //массив показывающий занятость столбца
            
            
            for(int i =0; i<xRow; i++)totalRows[i]=0; //заполняем массив активных столбцов в игре
            
            for(BlockNode *node in [self getAllBlocks]) //проходимся по всем блокам в сцене
            {
                
                if(node.row > totalRows[node.col]) //если текущий блок активен
                {
                    totalRows[node.col] = node.row; //обнуляем его в массиве активных столбцов
                }
            }
            
            //[self nodeFode:[self topNodes] andIt:0];
            
            //смотрим сверху на каждый столбец в игре и скидываем столько блоков сколько нужно
            for(int col = 0; col<xRow; col++) //проходимся по каждой строке
            {
                
                while(totalRows[col] < yRow - 1) //пока все столбцы не будут заполнены
                {
                    //создаем блок
                    CGFloat port = 640/xRow;
                    
                    NSUInteger indecs = arc4random() % _colors.count;
                    
                    BlockNode * node = [[BlockNode alloc] initWithRow:totalRows[col]+1
                                                           andCollumn:col
                                                            withColor:[_colors objectAtIndex:indecs]
                                                              andSize:CGSizeMake(port, port) andTop:blockTop];
                    
                    
                    [self.scene addChild:node]; //создаем блок
                    
                    ++totalRows[col];//регистрируем его в массиве как активный
                    
                }
            }
            //-----------------------------------------------------------------------------------------------
        }
    }
}

- (void)nodeFode:(NSUInteger)num andIt:(NSUInteger)it{
    if(num < 1132){blockTop = 0;}
    
    if(num <= 1132 * it)
    {
        blockTop = it;
        
    } else [self nodeFode:num andIt:(it+1)];
}

- (NSUInteger)topNodes{
    NSUInteger topSign = 0;
    
    for(BlockNode *node in [self getAllBlocks])
    {
        if(topSign < node.position.y){topSign = node.position.y;}
    }
    
    return topSign;
}

- (void)gameEnded{
    
    [player setVolume:0];
    
    gameState = STOPPED;//игра переходит в состоянее STOPPED
    
    if(self.gameLevel == 1){
        
        NSNumber * oldScore = [[NSUserDefaults standardUserDefaults]objectForKey:@"scoreTo1"];//достаем очки из памяти приложения
        NSInteger oldScoreIn = [oldScore integerValue]; //конвертируем в integer
        
        if(score > oldScoreIn)
        {
            
            NSNumber * scoreOb = [NSNumber numberWithInteger:score]; //мы их конвертируем в объект
            
            [[NSUserDefaults standardUserDefaults]setObject:scoreOb forKey:@"scoreTo1"]; //и заменяем старые данные в памяти приложения
            
            SKSpriteNode * newRecord = [SKSpriteNode spriteNodeWithImageNamed:@"newRecord"];
            newRecord.position = CGPointMake(500, 630);
            newRecord.zPosition = 12;
            
            SKAction * act =    [SKAction scaleTo:0.70 duration:0.30];
            SKAction * act2 =   [SKAction scaleTo:1 duration:0.30];
            SKAction * acts =   [SKAction sequence:@[act,act2]];
            
            [self addChild:newRecord];
            
            [newRecord runAction:[SKAction repeatActionForever:acts]];
            
            oldScoreIn = score;
            
        }
        
        SKSpriteNode * scNum_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * scNum_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * scNum_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        
        SKSpriteNode * bscNum_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * bscNum_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * bscNum_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        
        NSUInteger scorePer = score;
        
        int a = (int)scorePer;
        int n1, n2, n3;
        
        n1 = a / 100;
        n2 = (a - n1 * 100) / 10;
        n3 = (a - n1 * 100 - n2 * 10);
        
        SKTexture * num0 = [numbersList textureNamed:@"0"];
        SKTexture * num1 = [numbersList textureNamed:@"1"];
        SKTexture * num2 = [numbersList textureNamed:@"2"];
        SKTexture * num3 = [numbersList textureNamed:@"3"];
        SKTexture * num4 = [numbersList textureNamed:@"4"];
        SKTexture * num5 = [numbersList textureNamed:@"5"];
        SKTexture * num6 = [numbersList textureNamed:@"6"];
        SKTexture * num7 = [numbersList textureNamed:@"7"];
        SKTexture * num8 = [numbersList textureNamed:@"8"];
        SKTexture * num9 = [numbersList textureNamed:@"9"];
        
        if(n1 == 0 && a > 999){[scNum_1 setTexture:num0];}else{[scNum_1 setTexture:nil];}
        if(n1 == 1){[scNum_1 setTexture:num1];}
        if(n1 == 2){[scNum_1 setTexture:num2];}
        if(n1 == 3){[scNum_1 setTexture:num3];}
        if(n1 == 4){[scNum_1 setTexture:num4];}
        if(n1 == 5){[scNum_1 setTexture:num5];}
        if(n1 == 6){[scNum_1 setTexture:num6];}
        if(n1 == 7){[scNum_1 setTexture:num7];}
        if(n1 == 8){[scNum_1 setTexture:num8];}
        if(n1 == 9){[scNum_1 setTexture:num9];}
        
        if(n2 == 0 && a > 99){[scNum_2 setTexture:num0];}else{[scNum_2 setTexture:nil];}
        if(n2 == 1){[scNum_2 setTexture:num1];}
        if(n2 == 2){[scNum_2 setTexture:num2];}
        if(n2 == 3){[scNum_2 setTexture:num3];}
        if(n2 == 4){[scNum_2 setTexture:num4];}
        if(n2 == 5){[scNum_2 setTexture:num5];}
        if(n2 == 6){[scNum_2 setTexture:num6];}
        if(n2 == 7){[scNum_2 setTexture:num7];}
        if(n2 == 8){[scNum_2 setTexture:num8];}
        if(n2 == 9){[scNum_2 setTexture:num9];}
        
        if(n3 == 0){[scNum_3 setTexture:num0];}
        if(n3 == 1){[scNum_3 setTexture:num1];}
        if(n3 == 2){[scNum_3 setTexture:num2];}
        if(n3 == 3){[scNum_3 setTexture:num3];}
        if(n3 == 4){[scNum_3 setTexture:num4];}
        if(n3 == 5){[scNum_3 setTexture:num5];}
        if(n3 == 6){[scNum_3 setTexture:num6];}
        if(n3 == 7){[scNum_3 setTexture:num7];}
        if(n3 == 8){[scNum_3 setTexture:num8];}
        if(n3 == 9){[scNum_3 setTexture:num9];}
        
        
        scNum_1.position = CGPointMake(337, 431);
        scNum_1.zPosition = 10;
        [self addChild:scNum_1];
        
        scNum_2.position = CGPointMake(414, 431);
        scNum_2.zPosition = 10;
        [self addChild:scNum_2];
        
        scNum_3.position = CGPointMake(487, 431);
        scNum_3.zPosition = 10;
        [self addChild:scNum_3];
        
        
        //---------------------------------------------------------------------------
        //best score
        
        NSUInteger scorePer2 = oldScoreIn;
        
        int a2 = (int)scorePer2;
        int n12, n22, n32;
        
        n12 = a2 / 100;
        n22 = (a2 - n12 * 100) / 10;
        n32 = (a2 - n12 * 100 - n22 * 10);
        
        SKTexture * bnum0 = [numbersList textureNamed:@"0"];
        SKTexture * bnum1 = [numbersList textureNamed:@"1"];
        SKTexture * bnum2 = [numbersList textureNamed:@"2"];
        SKTexture * bnum3 = [numbersList textureNamed:@"3"];
        SKTexture * bnum4 = [numbersList textureNamed:@"4"];
        SKTexture * bnum5 = [numbersList textureNamed:@"5"];
        SKTexture * bnum6 = [numbersList textureNamed:@"6"];
        SKTexture * bnum7 = [numbersList textureNamed:@"7"];
        SKTexture * bnum8 = [numbersList textureNamed:@"8"];
        SKTexture * bnum9 = [numbersList textureNamed:@"9"];
        
        if(n12 == 0 && a2 > 999){[bscNum_1 setTexture:bnum0];}else{[bscNum_1 setTexture:nil];}
        if(n12 == 1){[bscNum_1 setTexture:bnum1];}
        if(n12 == 2){[bscNum_1 setTexture:bnum2];}
        if(n12 == 3){[bscNum_1 setTexture:bnum3];}
        if(n12 == 4){[bscNum_1 setTexture:bnum4];}
        if(n12 == 5){[bscNum_1 setTexture:bnum5];}
        if(n12 == 6){[bscNum_1 setTexture:bnum6];}
        if(n12 == 7){[bscNum_1 setTexture:bnum7];}
        if(n12 == 8){[bscNum_1 setTexture:bnum8];}
        if(n12 == 9){[bscNum_1 setTexture:bnum9];}
        
        if(n22 == 0 && a2 > 99){[bscNum_2 setTexture:bnum0];}else{[bscNum_2 setTexture:nil];}
        if(n22 == 1){[bscNum_2 setTexture:bnum1];}
        if(n22 == 2){[bscNum_2 setTexture:bnum2];}
        if(n22 == 3){[bscNum_2 setTexture:bnum3];}
        if(n22 == 4){[bscNum_2 setTexture:bnum4];}
        if(n22 == 5){[bscNum_2 setTexture:bnum5];}
        if(n22 == 6){[bscNum_2 setTexture:bnum6];}
        if(n22 == 7){[bscNum_2 setTexture:bnum7];}
        if(n22 == 8){[bscNum_2 setTexture:bnum8];}
        if(n22 == 9){[bscNum_2 setTexture:bnum9];}
        
        if(n32 == 0){[bscNum_3 setTexture:bnum0];}
        if(n32 == 1){[bscNum_3 setTexture:bnum1];}
        if(n32 == 2){[bscNum_3 setTexture:bnum2];}
        if(n32 == 3){[bscNum_3 setTexture:bnum3];}
        if(n32 == 4){[bscNum_3 setTexture:bnum4];}
        if(n32 == 5){[bscNum_3 setTexture:bnum5];}
        if(n32 == 6){[bscNum_3 setTexture:bnum6];}
        if(n32 == 7){[bscNum_3 setTexture:bnum7];}
        if(n32 == 8){[bscNum_3 setTexture:bnum8];}
        if(n32 == 9){[bscNum_3 setTexture:bnum9];}
        
        
        bscNum_1.position = CGPointMake(337, 318);
        bscNum_1.zPosition = 10;
        [self addChild:bscNum_1];
        
        bscNum_2.position = CGPointMake(414, 318);
        bscNum_2.zPosition = 10;
        [self addChild:bscNum_2];
        
        bscNum_3.position = CGPointMake(487, 318);
        bscNum_3.zPosition = 10;
        [self addChild:bscNum_3];
        
        //---------------------------------------------------------------------------
        
    }
    
    if(self.gameLevel == 2){
        
        NSNumber * oldScore = [[NSUserDefaults standardUserDefaults]objectForKey:@"scoreTo2"];//достаем очки из памяти приложения
        NSInteger oldScoreIn = [oldScore integerValue]; //конвертируем в integer
        
        if(timeLeftRounded < oldScoreIn || oldScoreIn == 0)
        {
            
            NSNumber * scoreOb = [NSNumber numberWithInteger:timeLeftRounded]; //мы их конвертируем в объект
            
            [[NSUserDefaults standardUserDefaults]setObject:scoreOb forKey:@"scoreTo2"]; //и заменяем старые данные в памяти приложения
            
            SKSpriteNode * newRecord = [SKSpriteNode spriteNodeWithImageNamed:@"newRecord"];
            newRecord.position = CGPointMake(500, 630);
            newRecord.zPosition = 12;
            
            SKAction * act =    [SKAction scaleTo:0.70 duration:0.30];
            SKAction * act2 =   [SKAction scaleTo:1 duration:0.30];
            SKAction * acts =   [SKAction sequence:@[act,act2]];
            
            [self addChild:newRecord];
            
            [newRecord runAction:[SKAction repeatActionForever:acts]];
            
            oldScoreIn = timeLeftRounded;
            
        }
        
        
        SKSpriteNode * scNum_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * scNum_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * scNum_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        
        SKSpriteNode * bscNum_1 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * bscNum_2 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        SKSpriteNode * bscNum_3 = [SKSpriteNode spriteNodeWithImageNamed:@"0"];
        
        NSUInteger scorePer = timeLeftRounded;
        
        int a = (int)scorePer;
        int n1, n2, n3;
        
        n1 = a / 100;
        n2 = (a - n1 * 100) / 10;
        n3 = (a - n1 * 100 - n2 * 10);
        
        SKTexture * num0 = [numbersList textureNamed:@"0"];
        SKTexture * num1 = [numbersList textureNamed:@"1"];
        SKTexture * num2 = [numbersList textureNamed:@"2"];
        SKTexture * num3 = [numbersList textureNamed:@"3"];
        SKTexture * num4 = [numbersList textureNamed:@"4"];
        SKTexture * num5 = [numbersList textureNamed:@"5"];
        SKTexture * num6 = [numbersList textureNamed:@"6"];
        SKTexture * num7 = [numbersList textureNamed:@"7"];
        SKTexture * num8 = [numbersList textureNamed:@"8"];
        SKTexture * num9 = [numbersList textureNamed:@"9"];
        
        if(n1 == 0 && a > 999){[scNum_1 setTexture:num0];}else{[scNum_1 setTexture:nil];}
        if(n1 == 1){[scNum_1 setTexture:num1];}
        if(n1 == 2){[scNum_1 setTexture:num2];}
        if(n1 == 3){[scNum_1 setTexture:num3];}
        if(n1 == 4){[scNum_1 setTexture:num4];}
        if(n1 == 5){[scNum_1 setTexture:num5];}
        if(n1 == 6){[scNum_1 setTexture:num6];}
        if(n1 == 7){[scNum_1 setTexture:num7];}
        if(n1 == 8){[scNum_1 setTexture:num8];}
        if(n1 == 9){[scNum_1 setTexture:num9];}
        
        if(n2 == 0 && a > 99){[scNum_2 setTexture:num0];}else{[scNum_2 setTexture:nil];}
        if(n2 == 1){[scNum_2 setTexture:num1];}
        if(n2 == 2){[scNum_2 setTexture:num2];}
        if(n2 == 3){[scNum_2 setTexture:num3];}
        if(n2 == 4){[scNum_2 setTexture:num4];}
        if(n2 == 5){[scNum_2 setTexture:num5];}
        if(n2 == 6){[scNum_2 setTexture:num6];}
        if(n2 == 7){[scNum_2 setTexture:num7];}
        if(n2 == 8){[scNum_2 setTexture:num8];}
        if(n2 == 9){[scNum_2 setTexture:num9];}
        
        if(n3 == 0){[scNum_3 setTexture:num0];}
        if(n3 == 1){[scNum_3 setTexture:num1];}
        if(n3 == 2){[scNum_3 setTexture:num2];}
        if(n3 == 3){[scNum_3 setTexture:num3];}
        if(n3 == 4){[scNum_3 setTexture:num4];}
        if(n3 == 5){[scNum_3 setTexture:num5];}
        if(n3 == 6){[scNum_3 setTexture:num6];}
        if(n3 == 7){[scNum_3 setTexture:num7];}
        if(n3 == 8){[scNum_3 setTexture:num8];}
        if(n3 == 9){[scNum_3 setTexture:num9];}
        
        
        scNum_1.position = CGPointMake(337, 431);
        scNum_1.zPosition = 10;
        [self addChild:scNum_1];
        
        scNum_2.position = CGPointMake(414, 431);
        scNum_2.zPosition = 10;
        [self addChild:scNum_2];
        
        scNum_3.position = CGPointMake(487, 431);
        scNum_3.zPosition = 10;
        [self addChild:scNum_3];
        
        
        //---------------------------------------------------------------------------
        //best score
        
        NSUInteger scorePer2 = oldScoreIn;
        
        int a2 = (int)scorePer2;
        int n12, n22, n32;
        
        n12 = a2 / 100;
        n22 = (a2 - n12 * 100) / 10;
        n32 = (a2 - n12 * 100 - n22 * 10);
        
        SKTexture * bnum0 = [numbersList textureNamed:@"0"];
        SKTexture * bnum1 = [numbersList textureNamed:@"1"];
        SKTexture * bnum2 = [numbersList textureNamed:@"2"];
        SKTexture * bnum3 = [numbersList textureNamed:@"3"];
        SKTexture * bnum4 = [numbersList textureNamed:@"4"];
        SKTexture * bnum5 = [numbersList textureNamed:@"5"];
        SKTexture * bnum6 = [numbersList textureNamed:@"6"];
        SKTexture * bnum7 = [numbersList textureNamed:@"7"];
        SKTexture * bnum8 = [numbersList textureNamed:@"8"];
        SKTexture * bnum9 = [numbersList textureNamed:@"9"];
        
        if(n12 == 0 && a2 > 999){[bscNum_1 setTexture:bnum0];}else{[bscNum_1 setTexture:nil];}
        if(n12 == 1){[bscNum_1 setTexture:bnum1];}
        if(n12 == 2){[bscNum_1 setTexture:bnum2];}
        if(n12 == 3){[bscNum_1 setTexture:bnum3];}
        if(n12 == 4){[bscNum_1 setTexture:bnum4];}
        if(n12 == 5){[bscNum_1 setTexture:bnum5];}
        if(n12 == 6){[bscNum_1 setTexture:bnum6];}
        if(n12 == 7){[bscNum_1 setTexture:bnum7];}
        if(n12 == 8){[bscNum_1 setTexture:bnum8];}
        if(n12 == 9){[bscNum_1 setTexture:bnum9];}
        
        if(n22 == 0 && a2 > 99){[bscNum_2 setTexture:bnum0];}else{[bscNum_2 setTexture:nil];}
        if(n22 == 1){[bscNum_2 setTexture:bnum1];}
        if(n22 == 2){[bscNum_2 setTexture:bnum2];}
        if(n22 == 3){[bscNum_2 setTexture:bnum3];}
        if(n22 == 4){[bscNum_2 setTexture:bnum4];}
        if(n22 == 5){[bscNum_2 setTexture:bnum5];}
        if(n22 == 6){[bscNum_2 setTexture:bnum6];}
        if(n22 == 7){[bscNum_2 setTexture:bnum7];}
        if(n22 == 8){[bscNum_2 setTexture:bnum8];}
        if(n22 == 9){[bscNum_2 setTexture:bnum9];}
        
        if(n32 == 0){[bscNum_3 setTexture:bnum0];}
        if(n32 == 1){[bscNum_3 setTexture:bnum1];}
        if(n32 == 2){[bscNum_3 setTexture:bnum2];}
        if(n32 == 3){[bscNum_3 setTexture:bnum3];}
        if(n32 == 4){[bscNum_3 setTexture:bnum4];}
        if(n32 == 5){[bscNum_3 setTexture:bnum5];}
        if(n32 == 6){[bscNum_3 setTexture:bnum6];}
        if(n32 == 7){[bscNum_3 setTexture:bnum7];}
        if(n32 == 8){[bscNum_3 setTexture:bnum8];}
        if(n32 == 9){[bscNum_3 setTexture:bnum9];}
        
        
        bscNum_1.position = CGPointMake(337, 318);
        bscNum_1.zPosition = 10;
        [self addChild:bscNum_1];
        
        bscNum_2.position = CGPointMake(414, 318);
        bscNum_2.zPosition = 10;
        [self addChild:bscNum_2];
        
        bscNum_3.position = CGPointMake(487, 318);
        bscNum_3.zPosition = 10;
        [self addChild:bscNum_3];
        
        //---------------------------------------------------------------------------
        
        
    }
    
    scoreBoard.hidden = NO;
    timeBoard.hidden = NO;
    
    endMenuButtonToMenu = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButtonToMenu"];
    endMenuButtonToMenu.size = CGSizeMake(125, 125);
    endMenuButtonToMenu.zPosition = 9;
    endMenuButtonToMenu.position = CGPointMake(197 ,181);
    [self addChild:endMenuButtonToMenu];
    
    endMenuButtonToRestart = [SKSpriteNode spriteNodeWithImageNamed:@"menuDownButton"];
    endMenuButtonToRestart.size = CGSizeMake(125, 125);
    endMenuButtonToRestart.zPosition = 9;
    endMenuButtonToRestart.position = CGPointMake(435, 181);
    [self addChild:endMenuButtonToRestart];
    
    SKSpriteNode * endFon = [SKSpriteNode spriteNodeWithImageNamed:@"endFon"];
    endFon.position = CGPointMake(320, 566);
    endFon.size = CGSizeMake(640, 1132);
    endFon.zPosition = 8;
    [self addChild:endFon];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if(gameState == STARTING) //если игра еще в стостоянии STARTING
    {
        if(self.gameLevel != 3){startedTime = currentTime;} //сохраняем время начала игры
        gameState = PLAYING; //игра переходит в состояние PLAYING
        
        if(self.gameLevel != 3){
            scoreBoard.hidden = YES;
            timeBoard.hidden = YES;}
        
    }
    
    if(menuOn){timeInPause = currentTime - startPause;}
    
    if(gameState == PLAYING && self.gameLevel == 1 && !menuOn){
        
        startPause = currentTime;
        
        timeLeftRounded = ceil(time + (startedTime - currentTime)); //сохраняем в переменную текущее врея (оставшееся до конца игры) отнимаем от времени начала игры текущее время и прибавляем время на которое рассчитана игра
        
        NSUInteger scorePer = timeLeftRounded;
        
        int a = (int)scorePer;
        int n1, n2, n3;
        
        n1 = a / 100;
        n2 = (a - n1 * 100) / 10;
        n3 = (a - n1 * 100 - n2 * 10);
        
        SKTexture * num0 = [numbersList textureNamed:@"0"];
        SKTexture * num1 = [numbersList textureNamed:@"1"];
        SKTexture * num2 = [numbersList textureNamed:@"2"];
        SKTexture * num3 = [numbersList textureNamed:@"3"];
        SKTexture * num4 = [numbersList textureNamed:@"4"];
        SKTexture * num5 = [numbersList textureNamed:@"5"];
        SKTexture * num6 = [numbersList textureNamed:@"6"];
        SKTexture * num7 = [numbersList textureNamed:@"7"];
        SKTexture * num8 = [numbersList textureNamed:@"8"];
        SKTexture * num9 = [numbersList textureNamed:@"9"];
        
        if(n1 == 0 && a > 999){[tNum_1 setTexture:num0];}else{[tNum_1 setTexture:nil];}
        if(n1 == 1){[tNum_1 setTexture:num1];}
        if(n1 == 2){[tNum_1 setTexture:num2];}
        if(n1 == 3){[tNum_1 setTexture:num3];}
        if(n1 == 4){[tNum_1 setTexture:num4];}
        if(n1 == 5){[tNum_1 setTexture:num5];}
        if(n1 == 6){[tNum_1 setTexture:num6];}
        if(n1 == 7){[tNum_1 setTexture:num7];}
        if(n1 == 8){[tNum_1 setTexture:num8];}
        if(n1 == 9){[tNum_1 setTexture:num9];}
        
        if(n2 == 0 && a > 99){[tNum_2 setTexture:num0];}else{[tNum_2 setTexture:nil];}
        if(n2 == 1){[tNum_2 setTexture:num1];}
        if(n2 == 2){[tNum_2 setTexture:num2];}
        if(n2 == 3){[tNum_2 setTexture:num3];}
        if(n2 == 4){[tNum_2 setTexture:num4];}
        if(n2 == 5){[tNum_2 setTexture:num5];}
        if(n2 == 6){[tNum_2 setTexture:num6];}
        if(n2 == 7){[tNum_2 setTexture:num7];}
        if(n2 == 8){[tNum_2 setTexture:num8];}
        if(n2 == 9){[tNum_2 setTexture:num9];}
        
        if(n3 == 0){[tNum_3 setTexture:num0];}
        if(n3 == 1){[tNum_3 setTexture:num1];}
        if(n3 == 2){[tNum_3 setTexture:num2];}
        if(n3 == 3){[tNum_3 setTexture:num3];}
        if(n3 == 4){[tNum_3 setTexture:num4];}
        if(n3 == 5){[tNum_3 setTexture:num5];}
        if(n3 == 6){[tNum_3 setTexture:num6];}
        if(n3 == 7){[tNum_3 setTexture:num7];}
        if(n3 == 8){[tNum_3 setTexture:num8];}
        if(n3 == 9){[tNum_3 setTexture:num9];}
        
        if(timeLeftRounded <= 0) //если прошедшее время равно 0
        {
            gameState = STOPPED; //игра переходит в стостояние STOPPED
            
            [self gameEnded]; // и запускается метод конца игры
        }
    }
    
    if(gameState == PLAYING && self.gameLevel == 2 && !menuOn){
        
        startPause = currentTime;
        
        timeLeftRounded = ceil(currentTime - startedTime); //сохраняем в переменную текущее врея (оставшееся до конца игры) отнимаем от времени начала игры текущее время и прибавляем время на которое рассчитана игра
        
        NSUInteger scorePer = timeLeftRounded;
        
        int a = (int)scorePer;
        int n1, n2, n3;
        
        n1 = a / 100;
        n2 = (a - n1 * 100) / 10;
        n3 = (a - n1 * 100 - n2 * 10);
        
        SKTexture * num0 = [numbersList textureNamed:@"0"];
        SKTexture * num1 = [numbersList textureNamed:@"1"];
        SKTexture * num2 = [numbersList textureNamed:@"2"];
        SKTexture * num3 = [numbersList textureNamed:@"3"];
        SKTexture * num4 = [numbersList textureNamed:@"4"];
        SKTexture * num5 = [numbersList textureNamed:@"5"];
        SKTexture * num6 = [numbersList textureNamed:@"6"];
        SKTexture * num7 = [numbersList textureNamed:@"7"];
        SKTexture * num8 = [numbersList textureNamed:@"8"];
        SKTexture * num9 = [numbersList textureNamed:@"9"];
        
        if(n1 == 0 && a > 999){[tNum_1 setTexture:num0];}else{[tNum_1 setTexture:nil];}
        if(n1 == 1){[tNum_1 setTexture:num1];}
        if(n1 == 2){[tNum_1 setTexture:num2];}
        if(n1 == 3){[tNum_1 setTexture:num3];}
        if(n1 == 4){[tNum_1 setTexture:num4];}
        if(n1 == 5){[tNum_1 setTexture:num5];}
        if(n1 == 6){[tNum_1 setTexture:num6];}
        if(n1 == 7){[tNum_1 setTexture:num7];}
        if(n1 == 8){[tNum_1 setTexture:num8];}
        if(n1 == 9){[tNum_1 setTexture:num9];}
        
        if(n2 == 0 && a > 99){[tNum_2 setTexture:num0];}else{[tNum_2 setTexture:nil];}
        if(n2 == 1){[tNum_2 setTexture:num1];}
        if(n2 == 2){[tNum_2 setTexture:num2];}
        if(n2 == 3){[tNum_2 setTexture:num3];}
        if(n2 == 4){[tNum_2 setTexture:num4];}
        if(n2 == 5){[tNum_2 setTexture:num5];}
        if(n2 == 6){[tNum_2 setTexture:num6];}
        if(n2 == 7){[tNum_2 setTexture:num7];}
        if(n2 == 8){[tNum_2 setTexture:num8];}
        if(n2 == 9){[tNum_2 setTexture:num9];}
        
        if(n3 == 0){[tNum_3 setTexture:num0];}
        if(n3 == 1){[tNum_3 setTexture:num1];}
        if(n3 == 2){[tNum_3 setTexture:num2];}
        if(n3 == 3){[tNum_3 setTexture:num3];}
        if(n3 == 4){[tNum_3 setTexture:num4];}
        if(n3 == 5){[tNum_3 setTexture:num5];}
        if(n3 == 6){[tNum_3 setTexture:num6];}
        if(n3 == 7){[tNum_3 setTexture:num7];}
        if(n3 == 8){[tNum_3 setTexture:num8];}
        if(n3 == 9){[tNum_3 setTexture:num9];}
        
        if(score <= 0)
        {
            gameState = STOPPED; //игра переходит в стостояние STOPPED
            
            [self gameEnded]; // и запускается метод конца игры
        }
    }
    
    
    for(SKNode * node in self.scene.children)
    {
        node.position = CGPointMake(roundf(node.position.x), roundf(node.position.y)); //сжимаем значения для больших кадров
    }
    
}

@end
