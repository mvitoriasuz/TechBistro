import Image from 'next/image';
import Link from 'next/link';
import { ArrowLeft, Target, Heart, Award } from 'lucide-react';

export default function SobreNosPage() {
  return (
    <div className="font-sans antialiased bg-white selection:bg-[#C5A47E] selection:text-white">
      <nav className="bg-white border-b border-gray-200">
        <div className="container mx-auto px-8 py-6 flex justify-between items-center">
           <Link href="/" className="flex items-center gap-3">
            <Image src="/logo.svg" alt="Logo" width={30} height={30} />
            <span className="text-[#510006] font-bold tracking-[0.2em] uppercase text-sm">Techbistro</span>
          </Link>
          <Link href="/" className="flex items-center text-[10px] font-bold text-gray-500 hover:text-[#510006] uppercase tracking-widest transition-colors">
            <ArrowLeft className="w-4 h-4 mr-2" /> Voltar ao Início
          </Link>
        </div>
      </nav>

      <header className="py-24 bg-[#510006] text-white text-center relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('/images/fundo_restaurante.jpg')] bg-cover bg-center opacity-10"></div>
        <div className="relative z-10 container mx-auto px-8">
           <span className="text-[#C5A47E] font-bold tracking-[0.2em] text-[10px] uppercase mb-4 block">Nossa História</span>
           <h1 className="text-4xl md:text-5xl font-bold uppercase tracking-wide mb-6">A Evolução do Servir</h1>
           <div className="w-20 h-1 bg-[#C5A47E] mx-auto"></div>
        </div>
      </header>

      <main className="container mx-auto px-8 py-24 max-w-4xl">
         <div className="prose prose-lg text-gray-600 mx-auto text-justify mb-20 leading-loose">
            <p className="mb-6">
               A <strong>Techbistro</strong> nasceu da observação de um cenário comum: restaurantes incríveis com comidas maravilhosas, mas processos travados. Garçons sobrecarregados, clientes frustrados com a demora para pagar e erros simples de comunicação que geravam desperdício.
            </p>
            <p>
               Entendemos que a tecnologia não deveria substituir a hospitalidade, mas sim libertá-la. Criamos um ecossistema onde o operacional acontece de forma fluida e automática, permitindo que os donos de restaurante foquem no que realmente importa: a qualidade da comida e o bem-estar dos clientes.
            </p>
         </div>

         <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center p-8 bg-gray-50 rounded-sm border border-gray-100 hover:border-[#C5A47E] transition-colors">
               <Target className="w-8 h-8 text-[#510006] mx-auto mb-4" />
               <h3 className="text-xs font-bold uppercase tracking-widest mb-2 text-gray-900">Missão</h3>
               <p className="text-xs text-gray-500 leading-relaxed">Democratizar a tecnologia de ponta para restaurantes de todos os tamanhos, simplificando a gestão complexa.</p>
            </div>
            <div className="text-center p-8 bg-gray-50 rounded-sm border border-gray-100 hover:border-[#C5A47E] transition-colors">
               <Heart className="w-8 h-8 text-[#510006] mx-auto mb-4" />
               <h3 className="text-xs font-bold uppercase tracking-widest mb-2 text-gray-900">Valores</h3>
               <p className="text-xs text-gray-500 leading-relaxed">Transparência nos dados, elegância no design e obsessão pela eficiência operacional.</p>
            </div>
            <div className="text-center p-8 bg-gray-50 rounded-sm border border-gray-100 hover:border-[#C5A47E] transition-colors">
               <Award className="w-8 h-8 text-[#510006] mx-auto mb-4" />
               <h3 className="text-xs font-bold uppercase tracking-widest mb-2 text-gray-900">Visão</h3>
               <p className="text-xs text-gray-500 leading-relaxed">Ser a referência nacional em sistemas de autoatendimento e gestão gastronômica premium.</p>
            </div>
         </div>
      </main>

      <footer className="bg-[#1a1a1a] text-white py-12 border-t border-white/10">
        <div className="container mx-auto px-8 text-center">
          <Link href="/#contato" className="inline-block px-8 py-3 border border-white/20 text-[10px] font-bold uppercase tracking-widest hover:bg-[#C5A47E] hover:border-[#C5A47E] transition-all mb-8">
             Fale com a gente
          </Link>
          <p className="text-[10px] uppercase tracking-widest opacity-40">Techbistro &copy; Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  );
}