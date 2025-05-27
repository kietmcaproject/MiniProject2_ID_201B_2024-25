package com.codeclash.codeclash.controller;

import com.codeclash.codeclash.dto.AuthResponseDto;
import com.codeclash.codeclash.dto.LoginDto;
import com.codeclash.codeclash.dto.UserRegistrationDto;
import com.codeclash.codeclash.exceptions.EmailAlreadyExistsException;
import com.codeclash.codeclash.model.Room;
import com.codeclash.codeclash.model.User;
import com.codeclash.codeclash.service.AuthService;
import com.codeclash.codeclash.service.RoomService;
import com.codeclash.codeclash.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "http://192.168.9.100:3000", originPatterns = "http://localhost:3000"
)
@AllArgsConstructor
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserService userService;

    @Autowired
    private RoomService roomService;

    // Building Login API
    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginDto loginDto){

        // 1- Reciving the token from AuthService
        String token = authService.login(loginDto);

        // 2- Now we are set the token as a response using JwtAuthResponse Dto class
        AuthResponseDto authResponseDto = new AuthResponseDto();
        authResponseDto.setAccessToken(token);
        authResponseDto.setUsername(loginDto.getUsername());

        return new ResponseEntity<>(authResponseDto,HttpStatus.OK);
    }

    @PostMapping("/register")
    public ResponseEntity<UserRegistrationDto> register(@RequestBody UserRegistrationDto  user){
        userService.registerUser(user);
        return ResponseEntity.ok(user);
    }

    @ExceptionHandler
            (EmailAlreadyExistsException.class) public ResponseEntity<String> handleEmailExistsException(EmailAlreadyExistsException ex){
        return new ResponseEntity<>(ex.getMessage(),HttpStatus.CONFLICT);
    }

    // Get all users api
    @GetMapping("/room/getallroom")
    public List<Room> getAllRoom(){
        return roomService.getAllRoom();
    }

    // get room using roomCode
    @GetMapping("/room/getroom/{roomCode}")
    public Room getRoom(@PathVariable String roomCode){
        return roomService.getRoom(roomCode);
    }
}
