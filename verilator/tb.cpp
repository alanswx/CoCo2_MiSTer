
#include <fstream> // ifstream

#include "VCoCo2.h"
#include "VCoCo2_emu.h"
#include "VCoCo2_hps_io__S4e.h"
#include "VCoCo2_pll.h"

// #include "verilated.h"
#include <verilated_vcd_c.h>
#include "SDL2/SDL.h"

VCoCo2* top;
SDL_Window* window;
SDL_Surface* screen;
SDL_Surface* canvas;
bool running = true;

void setPixel(SDL_Surface* dst, int x, int y, int color) {
  *((Uint32*)(dst->pixels) + x + y * dst->w) = color;
}

int main(int argc, char** argv, char** env) {

  Verilated::commandArgs(argc, argv);

  window = SDL_CreateWindow(
    "CoCo2",
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOWPOS_UNDEFINED,
    640, 480,
    SDL_WINDOW_SHOWN
    //SDL_WINDOW_OPENGL
    //SDL_WINDOW_VULKAN
  );

  if (window == NULL) {
    printf("Could not create window: %s\n", SDL_GetError());
    return 1;
  }

  screen = SDL_GetWindowSurface(window);
  canvas = SDL_CreateRGBSurfaceWithFormat(0, 640, 480, 16, SDL_PIXELFORMAT_RGB888);

  printf("creating instance\n");

  top = new VCoCo2;
  top->eval();

  VCoCo2_hps_io__S4e* io = top->emu->hps_io;
  VCoCo2_pll* pll = top->emu->pll;

  if (argc > 1) {

    printf("loading ROM file\n");
    const char* romfile = argv[1];

    std::ifstream ifs(romfile, std::ios::in | std::ios::binary);
    if (!ifs) return -1;

    io->ioctl_addr = 0;
    io->ioctl_download = 1;
    io->ioctl_dout = ifs.get();
    top->CLK_50M = !top->CLK_50M;
    top->eval();

    while (!ifs.eof()) {

      if (top->CLK_50M) {
        io->ioctl_addr = io->ioctl_addr+1;
        io->ioctl_dout = ifs.get();
      }

      top->CLK_50M = !top->CLK_50M;
      top->eval();

    }

    io->ioctl_download = 0;
    printf("ROM loaded\n");
  }

  #if VM_TRACE			// If verilator was invoked with --trace
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("dump.vcd");	// Open the dump file
  #endif

  top->RESET = 0;

  int cycles = 0;
  float vgax = 0;
  int vgay = 0;
  bool hs = true;
  bool vs = true;
  bool dirty;

  int start_trace = 0;
  int stop_sim    = 1'000'000;
  bool tracing = false;

  printf("running instance\n");

  while (running) {


    #if VM_TRACE
      if (cycles > start_trace) tracing = true;
      if (cycles > stop_sim) running = false;
    #endif

    if (cycles == 1000) top->RESET = 1;
    if (cycles == 2000) top->RESET = 0;

    #if VM_TRACE
      if (tfp && tracing) tfp->dump(cycles);
    #endif

    top->eval();

    top->CLK_50M = !top->CLK_50M;

    if (dirty) {
      SDL_BlitSurface(canvas, NULL, screen, NULL);
      SDL_UpdateWindowSurface(window);
      SDL_FillRect(canvas, NULL, 0x0);
      printf("refresh\n");
      dirty = false;
    }


    if (pll->outclk_1) {

      if (!top->VGA_HS && hs) { // start of hsync ¯¯\__
        hs = false;
      }
      else if (top->VGA_HS && !hs) { // end of hsync __/¯¯
        hs = true;
        vgax = -192;
        vgay++;
      }
      else {
        vgax += 1;
      }

      if (!top->VGA_VS && vs) { // start of vsync ¯¯\__
        vs = false;
      }
      else if (top->VGA_VS && !vs) { // end of vsync __/¯¯
        vs = true;
        vgay = -31;
        dirty = true;
      }

      if (vgax >= 0 && vgax < 640 && vgay >= 0 && vgay < 480) {
        int c = top->VGA_R << 16 | top->VGA_G << 8 | top->VGA_B;
        setPixel(canvas, vgax, vgay, !hs || !vs ? 0 : c);
      }
    }


    if (cycles % 1000000 == 0) {
      printf("sim: %d %s\n", cycles, tracing == true ? "(tracing)" : "");
    }

    cycles++;


  }

  #if VM_TRACE
    if (tfp) tfp->close();
  #endif

  SDL_FreeSurface(screen);
  SDL_DestroyWindow(window);
  SDL_Quit();

  return 0;
}
