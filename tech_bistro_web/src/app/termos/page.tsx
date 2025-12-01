import Link from 'next/link';
import Image from 'next/image';
import { ArrowLeft, FileText } from 'lucide-react';

export default function TermosPage() {
  return (
    <div className="min-h-screen bg-white font-sans selection:bg-[#C5A47E] selection:text-white">
      <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
        <div className="container mx-auto px-8 py-4 flex justify-between items-center">
          <Link href="/" className="flex items-center text-gray-400 hover:text-[#510006] transition-colors text-[10px] font-bold uppercase tracking-widest">
            <ArrowLeft className="w-4 h-4 mr-2" /> Voltar
          </Link>
          <div className="flex items-center gap-2">
            <Image src="/logo.svg" alt="Logo" width={24} height={24} />
            <span className="font-bold text-[#510006] uppercase tracking-widest text-xs">Legal</span>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-8 py-16 max-w-3xl">
        <div className="flex items-center gap-4 mb-10">
           <div className="w-12 h-12 bg-[#510006]/5 rounded-full flex items-center justify-center">
              <FileText className="w-6 h-6 text-[#510006]" />
           </div>
           <h1 className="text-2xl font-bold text-gray-900 uppercase tracking-wide">Termos de Uso</h1>
        </div>
        
        <div className="space-y-12 text-gray-600 text-sm leading-loose text-justify border-l-2 border-gray-100 pl-8">
          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">1. Visão Geral</h2>
            <p>
              Estes termos de serviço regulam o uso deste site. Ao acessá-lo, você concorda com estes termos. O site Techbistro é uma plataforma informativa destinada a apresentar as soluções de tecnologia para restaurantes desenvolvidas por nossa equipe.
            </p>
          </section>

          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">2. Propriedade Intelectual</h2>
            <p>
              Todo o conteúdo apresentado neste site, incluindo textos, logotipos, imagens de demonstração, design e códigos, é propriedade exclusiva da Techbistro. É proibida a reprodução, distribuição ou criação de obras derivadas sem autorização expressa.
            </p>
          </section>

          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">3. Uso Permitido</h2>
            <p>
              Você pode visualizar, baixar e imprimir conteúdos deste site apenas para fins informativos pessoais e não comerciais, visando avaliar a contratação de nossos serviços. Qualquer uso indevido para engenharia reversa ou cópia de modelo de negócio é estritamente proibido.
            </p>
          </section>
          
          <section>
            <h2 className="text-[#510006] font-bold uppercase tracking-widest text-xs mb-4">4. Limitação de Responsabilidade</h2>
            <p>
              As informações contidas neste site são fornecidas. Embora nos esforcemos para manter o conteúdo atualizado, não garantimos a precisão absoluta de preços ou disponibilidade de planos em tempo real sem consulta prévia ao nosso time comercial.
            </p>
          </section>
        </div>
      </main>

      <footer className="bg-[#f8f8f8] border-t border-gray-200 py-8 mt-12">
        <div className="container mx-auto px-8 text-center">
          <p className="text-[10px] uppercase tracking-widest text-gray-400">Techbistro &copy; Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  );
}