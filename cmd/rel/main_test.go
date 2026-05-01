package main

import (
	"strings"
	"testing"
)

func TestParseRelArgs_NoArgsPrintsHelp(t *testing.T) {
	_, help, err := parseRelArgs(nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !help {
		t.Fatalf("expected help=true with no args")
	}
}

func TestParseRelArgs_HelpFlagAlone(t *testing.T) {
	for _, flag := range []string{"-h", "-?", "--help"} {
		_, help, err := parseRelArgs([]string{flag})
		if err != nil {
			t.Fatalf("%s: unexpected error: %v", flag, err)
		}
		if !help {
			t.Fatalf("%s: expected help=true", flag)
		}
	}
}

func TestParseRelArgs_HelpFlagMixed(t *testing.T) {
	_, _, err := parseRelArgs([]string{"v0.1.0", "-h"})
	if err == nil || err.Error() != "help flags must be used by themselves" {
		t.Fatalf("expected help-mixed error, got %v", err)
	}
}

func TestParseRelArgs_UnsupportedOption(t *testing.T) {
	_, _, err := parseRelArgs([]string{"--foo", "bar"})
	if err == nil || !strings.Contains(err.Error(), "unsupported option") {
		t.Fatalf("expected unsupported-option error, got %v", err)
	}
}

func TestParseRelArgs_WrongArgCount(t *testing.T) {
	_, _, err := parseRelArgs([]string{"v0.1.0"})
	if err == nil || err.Error() != `usage: rel vX.Y.Z "release message"` {
		t.Fatalf("expected usage error, got %v", err)
	}
}

func TestParseRelArgs_BadTag(t *testing.T) {
	_, _, err := parseRelArgs([]string{"0.1.0", "msg"})
	if err == nil || !strings.Contains(err.Error(), "release tag must match") {
		t.Fatalf("expected tag error, got %v", err)
	}
}

func TestParseRelArgs_EmptyMessage(t *testing.T) {
	_, _, err := parseRelArgs([]string{"v0.1.0", "   "})
	if err == nil || err.Error() != "release message must be non-empty" {
		t.Fatalf("expected empty-message error, got %v", err)
	}
}

func TestParseRelArgs_MessageBoundary(t *testing.T) {
	tag := "v0.1.0"

	msg80 := strings.Repeat("a", 80)
	cfg, help, err := parseRelArgs([]string{tag, msg80})
	if err != nil {
		t.Fatalf("80-char message rejected: %v", err)
	}
	if help {
		t.Fatalf("80-char accept should not signal help")
	}
	if cfg.message != msg80 {
		t.Fatalf("message round-trip mismatch")
	}

	msg81 := strings.Repeat("a", 81)
	_, _, err = parseRelArgs([]string{tag, msg81})
	if err == nil || err.Error() != "release message must be 80 characters or fewer" {
		t.Fatalf("expected 80-char error, got %v", err)
	}
}
