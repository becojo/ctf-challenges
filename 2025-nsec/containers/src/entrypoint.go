package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/sha256"
	_ "embed"
	"encoding/base64"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

var cmd string
var enc string
var state *model

//go:embed logo.txt
var logo string

func sha256Bin(key string) []byte {
	hash := sha256.Sum256([]byte(key))
	return hash[:]
}

func init() {
	cmd = strings.Join(os.Args[1:], " ")
	enc = os.Getenv("ENC")
	if cmd == "" || enc == "" || cmd == "\nnot-a-FLAG-: analyzing this binary is not a part of the goal of this challenge\n" {
		panic("no command given or ENC is empty")
	}

	input := textinput.New()
	input.Placeholder = "Please enter the password to unlock this container"
	input.CharLimit = 80
	input.Width = 80
	input.Prompt = "🔐 "
	input.Focus()

	state = &model{
		textInput: input,
	}
}

type model struct {
	textInput textinput.Model
	output    string
}

func (m model) Init() tea.Cmd {
	return textinput.Blink
}

var parts []string = []string{
	"F", "L", "A", "G", "-",
}

func (m model) View() string {
	_s := func() string {
		var s strings.Builder
		s.WriteString("Lock version: ")
		for i := range parts {
			s.WriteByte(parts[i][0])
		}
		b := sha256Bin("%c%v%s%s" + os.Getenv("TERM"))
		for i := range b {
			s.WriteString(fmt.Sprintf("%x", b[i]))
			if i > 15 {
				break
			}
		}

		return s.String() + "\r"
	}
	line := strings.Repeat("_", m.textInput.Width)
	secret := _s()
	view := logo + "\n\n" + secret + line + "\n\n" + m.textInput.View() + "\n" + line + "\n"
	if m.output != "" {
		view += "\nPress enter to exit..."
	}
	return view
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var c tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyEnter:
			if !m.textInput.Focused() {
				return m, tea.Quit
			}

			m.textInput.Blur()

			input := m.textInput.Value()
			cmd := exec.Command("sh", "-ec", cmd)
			cmd.Stdin = bytes.NewBuffer([]byte(input))
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr

			if err := cmd.Run(); err != nil {
				m.output = "Incorrect password"
				m.textInput.Prompt = "❌ "
				break
			}

			plaintext, err := decrypt(input, enc)
			if err != nil {
				m.output = "decryption failed"
				m.textInput.Prompt = "❌ "
				break
			}

			m.output = string(plaintext)
			m.textInput.Prompt = "✅ "
		case tea.KeyCtrlC, tea.KeyEsc:
			return m, tea.Quit
		}
	}

	if m.output != "" {
		m.textInput.SetValue(m.output)
	}

	m.textInput, c = m.textInput.Update(msg)

	return m, c
}

func main() {
	p := tea.NewProgram(state)
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}

func decrypt(key, encrypted string) (string, error) {
	// Decode base64url
	ciphertext, err := base64.URLEncoding.DecodeString(encrypted)
	if err != nil {
		return "", fmt.Errorf("base64 decode failed: %v", err)
	}

	// Extract IV (first 16 bytes) and actual ciphertext
	if len(ciphertext) < aes.BlockSize {
		return "", fmt.Errorf("ciphertext too short")
	}
	iv := ciphertext[:aes.BlockSize]
	ciphertext = ciphertext[aes.BlockSize:]

	// Create cipher
	block, err := aes.NewCipher(sha256Bin(key))
	if err != nil {
		return "", fmt.Errorf("failed to create cipher: %v", err)
	}

	// Create decrypter
	mode := cipher.NewCBCDecrypter(block, iv)

	// Decrypt in place
	plaintext := make([]byte, len(ciphertext))
	copy(plaintext, ciphertext)
	mode.CryptBlocks(plaintext, plaintext)

	// Remove padding
	return string(bytes.TrimRight(plaintext, " ")), nil
}
