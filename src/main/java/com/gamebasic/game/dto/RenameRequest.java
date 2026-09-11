package com.gamebasic.game.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RenameRequest {
    @NotBlank
    @Size(min = 2, max = 12)
    private String playerName;

    public String getPlayerName() {
        return playerName;
    }
}
