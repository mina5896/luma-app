package com.learning.dto;

import java.util.List;

public class GeminiTextRequest {
    private List<Content> contents;

    public GeminiTextRequest(String text) {
        this.contents = List.of(new Content(List.of(new Part(text))));
    }

    public List<Content> getContents() {
        return contents;
    }
}