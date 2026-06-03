package org.example.backend.controller;

import org.example.backend.Dto.CreateHelpLogDto;
import org.example.backend.Dto.helpLog.HelpLogResponseDto;
import org.example.backend.service.HelpLogService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/help-logs")
public class HelpLogController {

    @Autowired
    private HelpLogService helpLogService;

    @PostMapping("/")
    public ResponseEntity<HelpLogResponseDto> createHelpLog(@RequestBody CreateHelpLogDto createHelpLogDto) {
        return new ResponseEntity<>(helpLogService.createHelpLog(createHelpLogDto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HelpLogResponseDto> getHelpLogById(@PathVariable int id) {
        HelpLogResponseDto helpLog = helpLogService.getHelpLogById(id);
        if (helpLog == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(helpLog, HttpStatus.OK);
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<Page<HelpLogResponseDto>> getHelpLogsByActivitySession(
            @PathVariable int activitySessionId, Pageable pageable) {
        return new ResponseEntity<>(
                PaginationUtil.paginate(helpLogService.getHelpLogsByActivitySession(activitySessionId), pageable), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteHelpLog(@PathVariable int id) {
        if (helpLogService.getHelpLogById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        helpLogService.deleteHelpLog(id);
        return new ResponseEntity<>("HelpLog deleted successfully", HttpStatus.OK);
    }
}
