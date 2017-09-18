//
//  Constant.h
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

// script color --------------
#define colorFromHexString(_var_,_a_)  [UIColor colorWithRed:((float)((_var_ & 0xFF0000) >> 16))/255.0 green:((float)((_var_ & 0xFF00) >> 8))/255.0 blue:((float)(_var_ & 0xFF))/255.0 alpha:_a_]

// script localizable -----------
#define local(__key__)                 NSLocalizedString(__key__, nil)

// Server ---------------------


#endif /* Constant_h */

